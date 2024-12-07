shader_type spatial;

uniform vec3 emission_color = vec3(0.0, 0.8, 1.0); // Neon blue
uniform float emission_strength = 2.0;
uniform float metallic = 1.0;  // Fully metallic
uniform float roughness = 0.1; // Very glossy

void fragment() {
    EMISSION = emission_color * emission_strength; // Glow
    METALLIC = metallic;
    ROUGHNESS = roughness;
}
