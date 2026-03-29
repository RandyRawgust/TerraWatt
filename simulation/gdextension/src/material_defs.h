#pragma once
#include <cstdint>

namespace MatID {
constexpr uint16_t AIR = 0;
constexpr uint16_t DIRT = 1;
constexpr uint16_t STONE = 2;
constexpr uint16_t GRASS_DIRT = 3;
constexpr uint16_t COAL = 4;
constexpr uint16_t COPPER_ORE = 5;
constexpr uint16_t IRON_ORE = 6;
constexpr uint16_t CLAY = 7;
constexpr uint16_t WATER = 100;
constexpr uint16_t STEAM = 101;
constexpr uint16_t FIRE = 102;
constexpr uint16_t SMOKE = 103;
constexpr uint16_t ASH = 104;
constexpr uint16_t MUD = 105;
constexpr uint16_t COAL_DUST = 106;
constexpr uint16_t EMBERS = 107;
}

enum class MatCategory { SOLID, LIQUID, GAS, ENERGY };

struct MaterialDef {
	uint16_t id = 0;
	MatCategory category = MatCategory::GAS;
	float density = 0.0f;
	bool flammable = false;
	float ignition_temp = 0.0f;
	float burn_rate = 0.0f;
	bool conducts_elec = false;
	bool radioactive = false;
	bool falls_gravity = false;
	float viscosity = 0.0f;
};

inline MaterialDef make_def(uint16_t id, MatCategory cat, float dens, bool flam, float ign,
		float burn, bool elec, bool rad, bool fall, float visc) {
	MaterialDef d;
	d.id = id;
	d.category = cat;
	d.density = dens;
	d.flammable = flam;
	d.ignition_temp = ign;
	d.burn_rate = burn;
	d.conducts_elec = elec;
	d.radioactive = rad;
	d.falls_gravity = fall;
	d.viscosity = visc;
	return d;
}

inline MaterialDef get_mat(uint16_t id) {
	switch (id) {
		case MatID::AIR:
			return make_def(id, MatCategory::GAS, 0.0f, false, 0, 0, false, false, false, 0.0f);
		case MatID::DIRT:
			return make_def(id, MatCategory::SOLID, 2.0f, false, 0, 0, false, false, false, 0.0f);
		case MatID::STONE:
			return make_def(id, MatCategory::SOLID, 3.0f, false, 0, 0, false, false, false, 0.0f);
		case MatID::GRASS_DIRT:
			return make_def(id, MatCategory::SOLID, 2.0f, false, 0, 0, false, false, false, 0.0f);
		case MatID::COAL:
			return make_def(id, MatCategory::SOLID, 1.8f, true, 300.0f, 0.02f, false, false, false, 0.0f);
		case MatID::COPPER_ORE:
			return make_def(id, MatCategory::SOLID, 3.2f, false, 0, 0, false, false, false, 0.0f);
		case MatID::IRON_ORE:
			return make_def(id, MatCategory::SOLID, 3.5f, false, 0, 0, false, false, false, 0.0f);
		case MatID::CLAY:
			return make_def(id, MatCategory::SOLID, 2.2f, false, 0, 0, false, false, false, 0.0f);
		case MatID::WATER:
			return make_def(id, MatCategory::LIQUID, 1.0f, false, 0, 0, true, false, false, 0.1f);
		case MatID::STEAM:
			return make_def(id, MatCategory::GAS, 0.1f, false, 0, 0, false, false, false, 0.0f);
		case MatID::FIRE:
			return make_def(id, MatCategory::ENERGY, 0.1f, false, 0, 0, false, false, false, 0.0f);
		case MatID::SMOKE:
			return make_def(id, MatCategory::GAS, 0.2f, false, 0, 0, false, false, false, 0.0f);
		case MatID::ASH:
			return make_def(id, MatCategory::SOLID, 0.5f, false, 0, 0, false, false, true, 0.0f);
		case MatID::MUD:
			return make_def(id, MatCategory::LIQUID, 1.8f, false, 0, 0, false, false, false, 0.8f);
		case MatID::COAL_DUST:
			return make_def(id, MatCategory::SOLID, 0.8f, true, 200.0f, 0.05f, false, false, true, 0.0f);
		case MatID::EMBERS:
			return make_def(id, MatCategory::ENERGY, 0.3f, false, 0, 0, false, false, true, 0.0f);
		default:
			return make_def(MatID::AIR, MatCategory::GAS, 0.0f, false, 0, 0, false, false, false, 0.0f);
	}
}

inline bool is_gas_mat(uint16_t id) {
	return get_mat(id).category == MatCategory::GAS;
}

inline bool is_liquid_mat(uint16_t id) {
	return get_mat(id).category == MatCategory::LIQUID;
}

inline bool is_solid_mat(uint16_t id) {
	return get_mat(id).category == MatCategory::SOLID;
}
