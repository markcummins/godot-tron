shader_type spatial;

uniform vec3 emission_color = vec3(0.0, 0.2, 0.0); // Neon green
uniform float emission_strength = 0.2;
uniform float metallic = 1.0;  // Fully metallic
uniform float roughness = 0.1; // Very glossy
uniform float alpha = 0.5;     // Transparency level (0.0 = fully transparent, 1.0 = fully opaque)

void fragment() {
    EMISSION = emission_color * emission_strength; // Glow
    METALLIC = metallic;
    ROUGHNESS = roughness;
    ALPHA = alpha; // Set the transparency level
}
