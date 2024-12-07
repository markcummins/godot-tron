shader_type spatial;

uniform vec3 tile_color = vec3(0.0, 0.0, 0.0); // Tile color, set to black
uniform vec3 grid_color = vec3(1.0, 1.0, 1.0);
uniform float grid_thickness = 0.1;
uniform float tile_size = 0.1;

void fragment() {
    vec2 uv = UV * 10.0 / tile_size; 
    vec2 grid = fract(uv) - 0.5;
    vec2 grid_abs = abs(grid);

    float line_mask = step(grid_abs.x, grid_thickness) + step(grid_abs.y, grid_thickness);

    // Emission for glow on the lines
    vec3 emission_color = mix(vec3(0.0), grid_color, line_mask);
    EMISSION = emission_color;
    
    // Set the base color of the tile. Use line_mask to blend between tile_color and grid_color if desired.
    // If you want pure black tiles with white lines, just do:
    ALBEDO = tile_color;
}
