shader_type spatial;

uniform float amount : hint_range(0.0, 100.0) = 40.0;
uniform sampler2D albedo_texture;

void fragment() {
    vec2 uv = SCREEN_UV * 0.01;
    float a = fract(sin(dot(SCREEN_UV, vec2(12.9898, 78.233) * TIME)) * 438.5453) * 2.0;
    vec4 col = texture(albedo_texture, UV);
    col.a *= pow(a, amount);
    ALBEDO = col.rgb;
    ALPHA = col.a;
}