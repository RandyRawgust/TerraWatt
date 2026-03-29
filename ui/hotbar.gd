# SYSTEM: UI / Inventory
# AGENT: UI & Creatures Agent
# PURPOSE: Bottom hotbar displaying 10 inventory slots.
# Updates when Inventory signals fire.

extends HBoxContainer

class_name Hotbar

const SLOT_COUNT: int = 10

var _slots: Array = []
var _selected_slot: int = 0


func _ready() -> void:
	add_to_group("hotbar")
	_build_slots()
	Inventory.item_added.connect(_on_inventory_changed)
	Inventory.item_removed.connect(_on_inventory_changed)
	_refresh_display()
	_update_selection_highlight()


func get_selected_item_name() -> String:
	var keys: Array = Inventory.items.keys()
	if _selected_slot >= 0 and _selected_slot < keys.size():
		return str(keys[_selected_slot])
	return ""


func _build_slots() -> void:
	for i in range(SLOT_COUNT):
		var slot: Control = _make_slot()
		add_child(slot)
		_slots.append(slot)


func _make_slot() -> Control:
	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(40, 40)
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.name = "SlotVBox"
	var icon: TextureRect = TextureRect.new()
	icon.name = "Icon"
	icon.custom_minimum_size = Vector2(32, 32)
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var label: Label = Label.new()
	label.name = "CountLabel"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	label.add_theme_font_size_override("font_size", 9)
	vbox.add_child(icon)
	vbox.add_child(label)
	panel.add_child(vbox)
	return panel


func _on_inventory_changed(_type: String, _amount: int) -> void:
	_refresh_display()


func _refresh_display() -> void:
	var items: Array = Inventory.items.keys()
	for i in range(SLOT_COUNT):
		var slot: Control = _slots[i]
		var icon: TextureRect = slot.get_node("SlotVBox/Icon") as TextureRect
		var label: Label = slot.get_node("SlotVBox/CountLabel") as Label
		if i < items.size():
			var item_name: String = items[i]
			var count: int = Inventory.get_count(item_name)
			var tex_path: String = "res://assets/tiles/ores/%s_icon.png" % item_name
			if not ResourceLoader.exists(tex_path):
				tex_path = "res://assets/power/tier1/%s.png" % item_name
			if ResourceLoader.exists(tex_path):
				icon.texture = load(tex_path) as Texture2D
			else:
				icon.texture = null
			label.text = str(count)
		else:
			icon.texture = null
			label.text = ""


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	for i in range(10):
		var key: int = KEY_1 + i if i < 9 else KEY_0
		if event is InputEventKey and event.keycode == key and event.pressed and not event.echo:
			_selected_slot = i
			_update_selection_highlight()


# Item id at the selected slot, or "" if empty.
func get_selected_item_type() -> String:
	var items: Array = Inventory.items.keys()
	if _selected_slot >= 0 and _selected_slot < items.size():
		return items[_selected_slot] as String
	return ""


func _update_selection_highlight() -> void:
	for i in range(_slots.size()):
		var panel: PanelContainer = _slots[i] as PanelContainer
		if not panel:
			continue
		var sb: StyleBoxFlat = StyleBoxFlat.new()
		sb.bg_color = Color(0.102, 0.102, 0.18) # #1A1A2E
		sb.set_corner_radius_all(2)
		sb.set_border_width_all(1)
		if i == _selected_slot:
			sb.set_border_width_all(2)
			sb.border_color = Color(0.722, 0.451, 0.2) # copper
		else:
			sb.border_color = Color(0.22, 0.22, 0.28)
		panel.add_theme_stylebox_override("panel", sb)
