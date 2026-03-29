#include "sim_core.h"
#include <algorithm>

namespace {

bool neighbor_has_material(const std::vector<SimCell> &g, int w, int h, int x, int y, uint16_t mat) {
	const int dx[] = { 0, 0, -1, 1 };
	const int dy[] = { -1, 1, 0, 0 };
	for (int i = 0; i < 4; i++) {
		int nx = x + dx[i];
		int ny = y + dy[i];
		if (nx >= 0 && nx < w && ny >= 0 && ny < h) {
			if (g[nx + ny * w].material_id == mat) {
				return true;
			}
		}
	}
	return false;
}

} // namespace

SimCore::SimCore(int width_tiles, int height_tiles) {
	sim_width = std::max(1, width_tiles) * SIM_SCALE;
	sim_height = std::max(1, height_tiles) * SIM_SCALE;
	grid_a.resize(sim_width * sim_height);
	grid_b.resize(sim_width * sim_height);
	current = &grid_a;
	next = &grid_b;
	std::random_device rd;
	rng.seed(rd());
	oob_air = SimCell(MatID::AIR, 20.0f);
}

bool SimCore::in_bounds(int x, int y) const {
	return x >= 0 && x < sim_width && y >= 0 && y < sim_height;
}

SimCell &SimCore::get_cell(int x, int y) {
	if (!in_bounds(x, y)) {
		return oob_air;
	}
	return (*current)[idx(x, y)];
}

const SimCell &SimCore::get_cell(int x, int y) const {
	if (!in_bounds(x, y)) {
		static const SimCell air(MatID::AIR, 20.0f);
		return air;
	}
	return (*current)[idx(x, y)];
}

void SimCore::set_cell(int x, int y, const SimCell &cell) {
	if (!in_bounds(x, y)) {
		return;
	}
	(*current)[idx(x, y)] = cell;
}

void SimCore::set_tile(int tile_x, int tile_y, uint16_t material_id) {
	int ox = tile_x * SIM_SCALE;
	int oy = tile_y * SIM_SCALE;
	for (int dy = 0; dy < SIM_SCALE; dy++) {
		for (int dx = 0; dx < SIM_SCALE; dx++) {
			set_cell(ox + dx, oy + dy, SimCell(material_id, 20.0f));
		}
	}
}

uint16_t SimCore::get_tile_material(int tile_x, int tile_y) const {
	int ox = tile_x * SIM_SCALE;
	int oy = tile_y * SIM_SCALE;
	if (!in_bounds(ox, oy)) {
		return MatID::AIR;
	}
	return get_cell(ox, oy).material_id;
}

void SimCore::add_particle(int x, int y, uint16_t material_id, float temperature) {
	if (!in_bounds(x, y)) {
		return;
	}
	SimCell p(material_id, temperature);
	if (material_id == MatID::SMOKE || material_id == MatID::STEAM) {
		p.lifetime = 200;
	} else if (material_id == MatID::FIRE) {
		p.lifetime = 60;
	}
	(*current)[idx(x, y)] = p;
}

bool SimCore::has_active_cells() const {
	for (const SimCell &c : *current) {
		if (!c.is_air()) {
			return true;
		}
	}
	return false;
}

void SimCore::copy_current_to_next() {
	*next = *current;
}

void SimCore::step() {
	tick_count++;
	copy_current_to_next();

	std::vector<SimCell> &src = *current;
	std::vector<SimCell> &dst = *next;

	// --- Reactions (read src, write dst) ---
	for (int y = 0; y < sim_height; y++) {
		for (int x = 0; x < sim_width; x++) {
			int i = idx(x, y);
			const SimCell &c = src[i];
			SimCell out = c;
			out.flags &= ~CellFlags::UPDATED;

			if (c.material_id == MatID::FIRE) {
				if (neighbor_has_material(src, sim_width, sim_height, x, y, MatID::WATER)) {
					out = SimCell(MatID::STEAM, 105.0f);
					out.lifetime = 180;
				} else if (c.lifetime > 0) {
					out.lifetime = c.lifetime - 1;
					if (out.lifetime == 0) {
						out = SimCell(MatID::AIR, 20.0f);
					}
				}
			} else if (c.material_id == MatID::WATER && c.temperature >= 100.0f) {
				out = SimCell(MatID::STEAM, c.temperature);
				out.lifetime = 200;
			} else if (c.material_id == MatID::STEAM && c.temperature < 80.0f) {
				out = SimCell(MatID::WATER, 75.0f);
			}

			dst[i] = out;
		}
	}

	// --- Falling solids: ash, coal dust, embers (bottom-up) ---
	for (int y = sim_height - 2; y >= 0; y--) {
		int x0 = (tick_count & 1) ? (sim_width - 1) : 0;
		int x1 = (tick_count & 1) ? -1 : sim_width;
		int dxs = (tick_count & 1) ? -1 : 1;
		for (int x = x0; x != x1; x += dxs) {
			int i = idx(x, y);
			uint16_t m = dst[i].material_id;
			if (m != MatID::ASH && m != MatID::COAL_DUST && m != MatID::EMBERS) {
				continue;
			}
			int below = idx(x, y + 1);
			if (dst[below].material_id == MatID::AIR) {
				std::swap(dst[i], dst[below]);
			}
		}
	}

	// --- Water: fall then spread (bottom-up then mid pass) ---
	for (int y = sim_height - 2; y >= 0; y--) {
		int x0 = (tick_count & 1) ? (sim_width - 1) : 0;
		int x1 = (tick_count & 1) ? -1 : sim_width;
		int dxs = (tick_count & 1) ? -1 : 1;
		for (int x = x0; x != x1; x += dxs) {
			int i = idx(x, y);
			if (dst[i].material_id != MatID::WATER) {
				continue;
			}
			int below = idx(x, y + 1);
			if (dst[below].material_id == MatID::AIR) {
				std::swap(dst[i], dst[below]);
			}
		}
	}
	for (int pass = 0; pass < 2; pass++) {
		for (int y = sim_height - 1; y >= 0; y--) {
			int x0 = ((tick_count + pass) & 1) ? (sim_width - 1) : 0;
			int x1 = ((tick_count + pass) & 1) ? -1 : sim_width;
			int dxs = ((tick_count + pass) & 1) ? -1 : 1;
			for (int x = x0; x != x1; x += dxs) {
				int i = idx(x, y);
				if (dst[i].material_id != MatID::WATER) {
					continue;
				}
				std::uniform_int_distribution<int> lr(0, 1);
				int dir = lr(rng) ? 1 : -1;
				int nx = x + dir;
				if (nx >= 0 && nx < sim_width) {
					int ni = idx(nx, y);
					if (dst[ni].material_id == MatID::AIR) {
						std::swap(dst[i], dst[ni]);
					}
				}
			}
		}
	}

	// --- Mud: viscous liquid ---
	for (int y = sim_height - 2; y >= 0; y--) {
		for (int x = 0; x < sim_width; x++) {
			int i = idx(x, y);
			if (dst[i].material_id != MatID::MUD) {
				continue;
			}
			if ((rng() % 3) != 0) {
				continue;
			}
			int below = idx(x, y + 1);
			if (dst[below].material_id == MatID::AIR) {
				std::swap(dst[i], dst[below]);
			}
		}
	}

	// --- Steam: rise ---
	for (int y = 1; y < sim_height; y++) {
		int x0 = (tick_count & 1) ? (sim_width - 1) : 0;
		int x1 = (tick_count & 1) ? -1 : sim_width;
		int dxs = (tick_count & 1) ? -1 : 1;
		for (int x = x0; x != x1; x += dxs) {
			int i = idx(x, y);
			if (dst[i].material_id != MatID::STEAM) {
				continue;
			}
			int above = idx(x, y - 1);
			uint16_t up = dst[above].material_id;
			if (up == MatID::AIR || is_gas_mat(up)) {
				std::swap(dst[i], dst[above]);
			}
		}
	}

	// --- Smoke: rise + decay ---
	for (int y = 1; y < sim_height; y++) {
		for (int x = 0; x < sim_width; x++) {
			int i = idx(x, y);
			if (dst[i].material_id != MatID::SMOKE) {
				continue;
			}
			SimCell &cell = dst[i];
			if (cell.lifetime > 0) {
				cell.lifetime--;
			}
			if (cell.lifetime == 0) {
				cell = SimCell(MatID::AIR, 20.0f);
				continue;
			}
			int above = idx(x, y - 1);
			if (dst[above].material_id == MatID::AIR) {
				std::swap(dst[i], dst[above]);
			}
		}
	}

	// --- Fire: spread + smoke spawn ---
	for (int y = 0; y < sim_height; y++) {
		for (int x = 0; x < sim_width; x++) {
			int i = idx(x, y);
			if (dst[i].material_id != MatID::FIRE) {
				continue;
			}
			std::uniform_real_distribution<float> prob(0.0f, 1.0f);
			const int dx[] = { -1, 1, 0, 0 };
			const int dy[] = { 0, 0, -1, 1 };
			for (int k = 0; k < 4; k++) {
				int nx = x + dx[k];
				int ny = y + dy[k];
				if (!in_bounds(nx, ny)) {
					continue;
				}
				int ni = idx(nx, ny);
				uint16_t mid = dst[ni].material_id;
				const MaterialDef &def = get_mat(mid);
				if (def.flammable && mid != MatID::FIRE) {
					if (prob(rng) < 0.12f) {
						dst[ni].material_id = MatID::FIRE;
						dst[ni].temperature = 400.0f;
						dst[ni].lifetime = 40;
					}
				}
			}
			if (y > 0) {
				int ai = idx(x, y - 1);
				if (dst[ai].material_id == MatID::AIR && prob(rng) < 0.35f) {
					dst[ai] = SimCell(MatID::SMOKE, 80.0f);
					dst[ai].lifetime = 160;
				}
			}
		}
	}

	std::swap(current, next);
}
