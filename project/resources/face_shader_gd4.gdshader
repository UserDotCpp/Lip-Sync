shader_type spatial;
//render_mode unshaded;

uniform sampler2D target_texture : source_color;
uniform int colum_index = 0;
uniform int row_index = 0;
uniform int total_frames = 4;

void fragment() {
	float texture_size_scaled_down = 1.00 / float(total_frames);
	vec2 offset = vec2(float(colum_index) * texture_size_scaled_down, float(row_index) * texture_size_scaled_down);
	ALBEDO = texture(target_texture, UV + offset).rgb;
	ALPHA = texture(target_texture, UV + offset).a;
}
