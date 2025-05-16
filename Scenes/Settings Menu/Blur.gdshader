shader_type canvas_item;

uniform float brightness: hint_range(0.0, 5.0) = 1.0;
uniform float amount: hint_range(0.0, 5.0);
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

void fragment() {
	vec3 c = textureLod(screen_texture, SCREEN_UV, amount).rgb;
	COLOR.rgb = mix(vec3(0.0), c.rgb, brightness);
}