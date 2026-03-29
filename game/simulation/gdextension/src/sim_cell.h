#pragma once
#include <cstdint>

namespace CellFlags {
constexpr uint8_t UPDATED = 0x01;
constexpr uint8_t WET = 0x02;
constexpr uint8_t BURNING = 0x04;
constexpr uint8_t FALLING = 0x08;
}

struct SimCell {
	uint16_t material_id = 0;
	float temperature = 20.0f;
	uint8_t flags = 0;
	uint8_t lifetime = 255;

	SimCell() = default;
	SimCell(uint16_t mat, float temp = 20.0f)
			: material_id(mat), temperature(temp), flags(0), lifetime(255) {}

	bool is_air() const { return material_id == 0; }
	bool is_updated() const { return flags & CellFlags::UPDATED; }
	bool is_wet() const { return flags & CellFlags::WET; }
	bool is_burning() const { return flags & CellFlags::BURNING; }
};
