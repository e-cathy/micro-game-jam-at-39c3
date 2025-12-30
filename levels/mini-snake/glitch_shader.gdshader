shader_type canvas_item;

uniform sampler2D ccc_tex : source_color;
uniform sampler2D glitch_tex : source_color;
uniform sampler2D screen_tex : hint_screen_texture, source_color;


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = texture(ccc_tex, UV) * (vec4(1) - texture(screen_tex, UV)) +
	texture(glitch_tex, UV) * texture(screen_tex, UV);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
