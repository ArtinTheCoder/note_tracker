shader_type canvas_item;

uniform float size : hint_range(1.0, 100.0) = 25.0;
uniform float speed : hint_range(0.0, 10.0) = 1.0;
uniform float direction_x : hint_range(-1.0, 1.0) = 1.0; // Horizontal movement
uniform float direction_y : hint_range(-1.0, 1.0) = 1.0; // Vertical movement
uniform sampler2D movement_texture : source_color; // The texture to use for movement effect
uniform float opacity : hint_range(0.0, 1.0) = 0.5; // Control opacity
uniform bool is_paused = false; // Pause/play toggle

void fragment() {
    // Calculate movement direction and speed
    float time_offset = is_paused ? 0.0 : TIME * speed;
    vec2 direction = normalize(vec2(direction_x, direction_y));
    vec2 movement = direction * time_offset;

    // Modify UV coordinates based on movement
    vec2 modified_uv = UV - (movement / size);

    // Sample the texture with modified UV coordinates
    vec4 texture_color = texture(movement_texture, modified_uv);

    // Multiply the alpha channel by the opacity uniform
    texture_color.a *= opacity;

    COLOR = texture_color;
}