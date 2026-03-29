#pragma once

#include "sim_core.h"
#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <memory>

using namespace godot;

class TerrawattSimNode : public Node {
	GDCLASS(TerrawattSimNode, Node)

protected:
	static void _bind_methods();

public:
	TerrawattSimNode();
	~TerrawattSimNode() override = default;

	void step(double delta);

	int get_cell_material(int x, int y) const;
	float get_cell_temperature(int x, int y) const;
	int get_cell_flags(int x, int y) const;
	void set_cell_material(int x, int y, int material_id);
	void add_particle(int x, int y, int material_id);

	int get_sim_width() const;
	int get_sim_height() const;

	void set_tile_width_tiles(int w);
	int get_tile_width_tiles() const;
	void set_tile_height_tiles(int h);
	int get_tile_height_tiles() const;

private:
	void rebuild_sim_if_needed();
	void emit_dirty_region();

	int tile_width_tiles = 32;
	int tile_height_tiles = 32;
	std::unique_ptr<SimCore> sim;
};
