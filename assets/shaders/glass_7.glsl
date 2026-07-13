void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // === Parameters ===
    float refractiveIndex = 1.5;          // 1.0 = no lens effect, >1 = stronger lens
    float chromaticAberration = 0.02;     // 0.0 = no color fringing, >0 = more fringing

    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord / iResolution.xy;
    vec2 mouse = iMouse.xy;
    if (length(mouse) < 1.0) {
        mouse = iResolution.xy / 2.0;
    }

    vec2 m2 = (uv - mouse / iResolution.xy);
    
    float roundedBox = pow(abs(m2.x * iResolution.x / iResolution.y), 8.0) +
                       pow(abs(m2.y), 8.0);
    
    float rb1 = clamp((1.0 - roundedBox * 10000.0) * 8.0, 0.0, 1.0); // rounded box
    float rb2 = clamp((0.95 - roundedBox * 9500.0) * 16.0, 0.0, 1.0)
              - clamp(pow(0.9 - roundedBox * 9500.0, 1.0) * 16.0, 0.0, 1.0); // borders
    float rb3 = clamp((1.5 - roundedBox * 11000.0) * 2.0, 0.0, 1.0)
              - clamp(pow(1.0 - roundedBox * 11000.0, 1.0) * 2.0, 0.0, 1.0); // shadow gradient

    fragColor = vec4(0.0);
    
    if (rb1 + rb2 > 0.0) {
        vec2 distorted = (uv - 0.5) * (1.0 + (refractiveIndex - 1.0) * (1.0 - roundedBox * 5000.0)) + 0.5;
        vec2 caOffset = chromaticAberration * m2;

        float total = 0.0;
        for (float x = -4.0; x <= 4.0; x++) {
            for (float y = -4.0; y <= 4.0; y++) {
                vec2 offset = vec2(x, y) * 0.5 / iResolution.xy;
                
                vec3 col;
                col.r = texture(iChannel0, offset + distorted + caOffset).r;
                col.g = texture(iChannel0, offset + distorted).g;
                col.b = texture(iChannel0, offset + distorted - caOffset).b;

                fragColor += vec4(col, 1.0);
                total += 1.0;
            }
        }
        fragColor /= total;
        
        // Lighting
        float gradient = clamp((clamp(m2.y, 0.0, 0.2) + 0.1) / 2.0, 0.0, 1.0) +
                         clamp((clamp(-m2.y, -1000.0, 0.2) * rb3 + 0.1) / 2.0, 0.0, 1.0);
        fragColor = clamp(fragColor + vec4(rb1) * gradient + vec4(rb2) * 0.3, 0.0, 1.0);

    } else { 
        fragColor = texture(iChannel0, uv);
    }
}