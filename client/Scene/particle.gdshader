shader_type canvas_item;

uniform sampler2D emission_mask;
uniform vec2 emission_scale = vec2(1.0, 1.0);

void fragment() {
    vec2 scaled_uv = UV * emission_scale;
    vec4 mask = texture(emission_mask, scaled_uv);
    
    // Seules les zones blanches du masque émettent des particules
    if (mask.r < 0.5) {
        discard;  // Ne pas dessiner dans les zones sombres
    }

    COLOR = vec4(1.0);
}