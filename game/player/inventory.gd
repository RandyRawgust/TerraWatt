# SYSTEM: Player Inventory
# AGENT: UI & Creatures Agent (stub created by Foundation Agent)
# PURPOSE: Global inventory singleton. Tracks all collected items.

extends Node

# item_name (String) → count (int)
var items: Dictionary = {}

# Add `amount` of `item_type` to inventory.
func add_item(item_type: String, amount: int = 1) -> void:
	if items.has(item_type):
		items[item_type] += amount
	else:
		items[item_type] = amount
	item_added.emit(item_type, amount)

# Remove `amount` of `item_type`. Returns false if not enough.
func remove_item(item_type: String, amount: int = 1) -> bool:
	if not has_item(item_type, amount):
		return false
	items[item_type] -= amount
	if items[item_type] <= 0:
		items.erase(item_type)
	item_removed.emit(item_type, amount)
	return true

# Returns true if player has at least `amount` of `item_type`.
func has_item(item_type: String, amount: int = 1) -> bool:
	return items.get(item_type, 0) >= amount

# Returns count of item_type (0 if none).
func get_count(item_type: String) -> int:
	return items.get(item_type, 0)

signal item_added(item_type: String, amount: int)
signal item_removed(item_type: String, amount: int)
