shader_type canvas_item;

uniform vec2 circle_screen_pos = vec2(575.0, 325.0); // Center in screen pixels
uniform float radius = 50.0;    // Radius in pixels
uniform float radius_edge_size = 250.0;

void fragment() {
    // Get the current fragment's screen position in pixels
    vec2 screen_pos = FRAGCOORD.xy;

    // Distance from circle center
    float dist = distance(screen_pos, circle_screen_pos);

    // Smoothstep to occlude outside circle
	float alpha = smoothstep(radius, radius + radius_edge_size, dist);

    COLOR = vec4(0.0, 0.0, 0.0, alpha);
}