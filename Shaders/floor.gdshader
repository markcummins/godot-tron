shader_type spatial; // Use "canvas_item" for 2D

void fragment() {
    vec2 uv_scaled = UV * 10.0; // Adjust "10.0" for density
    vec2 check = fract(uv_scaled) * 2.0 - 1.0;
    float pattern = step(0.0, check.x * check.y);
    ALBEDO = vec3(pattern); // White and black
}