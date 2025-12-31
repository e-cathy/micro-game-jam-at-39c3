shader_type canvas_item;

uniform float opacity = 1.0;
uniform float speed = 1.0;
uniform vec2 amplitude = vec2(1.0);

void vertex() {
	VERTEX += round(vec2(
		sin(TIME * speed / 3600.0 * PI * 2.0 * 1000.0),
		cos(TIME * speed / 3600.0 * PI * 2.0 * 2000.0)
	) * amplitude);
}

void fragment() {
	COLOR = COLOR * opacity;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
