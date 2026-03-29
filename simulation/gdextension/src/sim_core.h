#pragma once
#include "sim_cell.h"
#include "material_defs.h"
#include <cstdint>
#include <random>
#include <vector>

class SimCore {
public:
	static constexpr int SIM_SCALE = 4;
	static constexpr int CHUNK_SIZE = 32;

	SimCore(int width_tiles, int height_tiles);
	~SimCore() = default;

	void step();

	SimCell &get_cell(int x, int y);
	const SimCell &get_cell(int x, int y) const;
	void set_cell(int x, int y, const SimCell &cell);

	void set_tile(int tile_x, int tile_y, uint16_t material_id);
	uint16_t get_tile_material(int tile_x, int tile_y) const;

	void add_particle(int x, int y, uint16_t material_id, float temperature = 20.0f);

	bool has_active_cells() const;

	int get_sim_width() const { return sim_width; }
	int get_sim_height() const { return sim_height; }

private:
	int sim_width = 0;
	int sim_height = 0;
	std::vector<SimCell> grid_a;
	std::vector<SimCell> grid_b;
	std::vector<SimCell> *current = nullptr;
	std::vector<SimCell> *next = nullptr;
	std::mt19937 rng;
	int tick_count = 0;
	SimCell oob_air;

	int idx(int x, int y) const { return y * sim_width + x; }

	bool in_bounds(int x, int y) const;

	void copy_current_to_next();
};
