shader_type spatial;

uniform vec3 tile_color = vec3(0.0, 0.0, 0.0); // Tile color, set to black
uniform vec3 grid_color = vec3(1.0, 1.0, 1.0); // Grid color, set to white
uniform float grid_thickness = 0.1; // Thickness of the grid lines
uniform float tile_size = 0.1; // Size of each tile
uniform float emission_intensity = 0.5; // Intensity of the grid line emission

void fragment() {
    vec2 uv = UV * 10.0 / tile_size; 
    vec2 grid = fract(uv) - 0.5;
    vec2 grid_abs = abs(grid);

    float line_mask = step(grid_abs.x, grid_thickness) + step(grid_abs.y, grid_thickness);

    // Emission for glow on the lines, scaled by intensity
    vec3 emission_color = mix(vec3(0.0), grid_color * emission_intensity, line_mask);
    EMISSION = emission_color;

    // Set the base color of the tile
    ALBEDO = tile_color;
}
