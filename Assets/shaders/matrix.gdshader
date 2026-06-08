shader_type canvas_item;

uniform sampler2D icon_tex : source_color;
// Zmniejszono domyślną szybkość z 0.5 na 0.2
uniform float speed : hint_range(0.05, 1.0) = 0.2; 
uniform float columns = 18.0;
uniform float intensity : hint_range(0.0, 2.0) = 1.0;
uniform float glitch_strength : hint_range(0.0, 0.1) = 0.02;

float random(float x) {
    return fract(sin(x * 12.9898) * 43758.5453123);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // --- 1. EFEKT GLITCH ---
    float glitch_time = floor(TIME * 15.0);
    float glitch_noise = random(floor(uv.y * 20.0) + glitch_time);
    if (glitch_noise > 0.95) {
        uv.x += (random(glitch_time) - 0.5) * glitch_strength;
    }

    // --- 2. LOGIKA MATRYCY ---
    float aspect = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
    vec2 fixed_uv = uv;
    fixed_uv.x *= 1.0 / aspect; 

    float col = floor(fixed_uv.x * columns);
    float col_uv = fract(fixed_uv.x * columns);

    float offset = random(col) * 10.0;
    // Zmniejszono mnożnik prędkości kolumn (wcześniej 0.4 - 0.9)
    float col_speed = mix(0.2, 0.5, random(col));

    // Przesunięcie pionowe
    float y = fract(uv.y + TIME * speed * col_speed + offset);
    
    float row_uv = fract(y * columns); 
    float row = floor(y * columns);

    float spawn = step(0.85, random(row + col * 7.43));

    // --- 3. TEKSTURA I EFEKT NEONU ---
    vec2 icon_tile_uv = vec2(col_uv, row_uv);
    vec4 icon = texture(icon_tex, icon_tile_uv);

    // Zmieniono kolor na ciemniejszy niebieski (wcześniej 0.1, 0.8, 1.0)
    vec3 icon_color = vec3(0.05, 0.3, 0.8);
    
    float glow = smoothstep(0.0, 0.5, icon.a) * 0.5;
    float fade = pow(1.0 - y, 2.5);
    
    // --- 4. FINALNE SKŁADANIE ---
    vec3 bg = vec3(0.01, 0.02, 0.04); 
    
    vec3 neon_effect = icon_color * (icon.a * 1.5 + glow);
    vec3 final_icons = neon_effect * spawn * fade * intensity;
    
    final_icons *= mix(0.8, 1.0, random(TIME));

    COLOR = vec4(bg + final_icons, 1.0);
}
