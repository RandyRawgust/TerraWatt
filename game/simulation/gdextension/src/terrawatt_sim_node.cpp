#include "terrawatt_sim_node.h"

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/rect2i.hpp>

void TerrawattSimNode::_bind_methods() {
	ClassDB::bind_method(D_METHOD("step", "delta"), &TerrawattSimNode::step);
	ClassDB::bind_method(D_METHOD("get_cell_material", "x", "y"), &TerrawattSimNode::get_cell_material);
	ClassDB::bind_method(D_METHOD("get_cell_temperature", "x", "y"), &TerrawattSimNode::get_cell_temperature);
	ClassDB::bind_method(D_METHOD("get_cell_flags", "x", "y"), &TerrawattSimNode::get_cell_flags);
	ClassDB::bind_method(D_METHOD("set_cell_material", "x", "y", "material_id"), &TerrawattSimNode::set_cell_material);
	ClassDB::bind_method(D_METHOD("add_particle", "x", "y", "material_id"), &TerrawattSimNode::add_particle);
	ClassDB::bind_method(D_METHOD("get_sim_width"), &TerrawattSimNode::get_sim_width);
	ClassDB::bind_method(D_METHOD("get_sim_height"), &TerrawattSimNode::get_sim_height);
	ClassDB::bind_method(D_METHOD("set_tile_width_tiles", "tiles"), &TerrawattSimNode::set_tile_width_tiles);
	ClassDB::bind_method(D_METHOD("get_tile_width_tiles"), &TerrawattSimNode::get_tile_width_tiles);
	ClassDB::bind_method(D_METHOD("set_tile_height_tiles", "tiles"), &TerrawattSimNode::set_tile_height_tiles);
	ClassDB::bind_method(D_METHOD("get_tile_height_tiles"), &TerrawattSimNode::get_tile_height_tiles);

	ADD_SIGNAL(MethodInfo("cells_updated", PropertyInfo(Variant::RECT2I, "region")));

	ADD_PROPERTY(PropertyInfo(Variant::INT, "tile_width_tiles", PROPERTY_HINT_RANGE, "1,512,1"), "set_tile_width_tiles", "get_tile_width_tiles");
	ADD_PROPERTY(PropertyInfo(Variant::INT, "tile_height_tiles", PROPERTY_HINT_RANGE, "1,512,1"), "set_tile_height_tiles", "get_tile_height_tiles");
}

TerrawattSimNode::TerrawattSimNode() {
	sim = std::make_unique<SimCore>(tile_width_tiles, tile_height_tiles);
}

void TerrawattSimNode::rebuild_sim_if_needed() {
	if (!sim) {
		sim = std::make_unique<SimCore>(tile_width_tiles, tile_height_tiles);
		return;
	}
	// Recreate only if dimensions changed (caller sets tiles then we need new grid)
	if (sim->get_sim_width() != tile_width_tiles * SimCore::SIM_SCALE ||
			sim->get_sim_height() != tile_height_tiles * SimCore::SIM_SCALE) {
		sim = std::make_unique<SimCore>(tile_width_tiles, tile_height_tiles);
	}
}

void TerrawattSimNode::step(double /*delta*/) {
	rebuild_sim_if_needed();
	if (!sim) {
		return;
	}
	sim->step();
	emit_dirty_region();
}

void TerrawattSimNode::emit_dirty_region() {
	if (!sim) {
		return;
	}
	Rect2i region(0, 0, sim->get_sim_width(), sim->get_sim_height());
	emit_signal("cells_updated", region);
}

int TerrawattSimNode::get_cell_material(int x, int y) const {
	if (!sim) {
		return 0;
	}
	return static_cast<int>(sim->get_cell(x, y).material_id);
}

float TerrawattSimNode::get_cell_temperature(int x, int y) const {
	if (!sim) {
		return 20.0f;
	}
	return sim->get_cell(x, y).temperature;
}

int TerrawattSimNode::get_cell_flags(int x, int y) const {
	if (!sim) {
		return 0;
	}
	return static_cast<int>(sim->get_cell(x, y).flags);
}

void TerrawattSimNode::set_cell_material(int x, int y, int material_id) {
	rebuild_sim_if_needed();
	if (!sim) {
		return;
	}
	sim->set_cell(x, y, SimCell(static_cast<uint16_t>(material_id), 20.0f));
}

void TerrawattSimNode::add_particle(int x, int y, int material_id) {
	rebuild_sim_if_needed();
	if (!sim) {
		return;
	}
	sim->add_particle(x, y, static_cast<uint16_t>(material_id), 20.0f);
}

int TerrawattSimNode::get_sim_width() const {
	return sim ? sim->get_sim_width() : 0;
}

int TerrawattSimNode::get_sim_height() const {
	return sim ? sim->get_sim_height() : 0;
}

void TerrawattSimNode::set_tile_width_tiles(int w) {
	tile_width_tiles = w > 0 ? w : 1;
	sim.reset();
	sim = std::make_unique<SimCore>(tile_width_tiles, tile_height_tiles);
}

int TerrawattSimNode::get_tile_width_tiles() const {
	return tile_width_tiles;
}

void TerrawattSimNode::set_tile_height_tiles(int h) {
	tile_height_tiles = h > 0 ? h : 1;
	sim.reset();
	sim = std::make_unique<SimCore>(tile_width_tiles, tile_height_tiles);
}

int TerrawattSimNode::get_tile_height_tiles() const {
	return tile_height_tiles;
}
