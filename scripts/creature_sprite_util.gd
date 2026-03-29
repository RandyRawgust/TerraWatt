# SYSTEM: Creatures
# AGENT: UI & Creatures Agent
# PURPOSE: Runtime placeholder textures until PixelLab art is wired in.

class_name CreatureSpriteUtil
extends Object


static func make_flat_texture(width: int, height: int, color: Color) -> Texture2D:
	var img: Image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	img.fill(color)
	return ImageTexture.create_from_image(img)


static func add_animation_frames(
	sf: SpriteFrames,
	anim_name: String,
	frame_count: int,
	width: int,
	height: int,
	base_color: Color,
	frame_variation: float = 0.04
) -> void:
	if not sf.has_animation(anim_name):
		sf.add_animation(anim_name)
	for i in frame_count:
		var c: Color = base_color.lightened(frame_variation * float(i))
		sf.add_frame(anim_name, make_flat_texture(width, height, c))
