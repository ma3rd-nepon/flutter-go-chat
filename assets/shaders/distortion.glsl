#iChannel0 "https://i.imgur.com/Tcgw968.jpeg"

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;

    // Сила марева возрастает к нижней части экрана
    float heat = pow(1.0 - uv.y, 2.5);

    // Длинные волны
    float wave1 = sin(uv.y * 12.0 + iTime * 4.5) * 0.020;
    float wave2 = sin(uv.y * 24.0 - iTime * 3.2) * 0.010;
    float wave3 = sin(uv.y *  8.0 + iTime * 2.8) * 0.015;

    float distortion = (wave1 + wave2 + wave3) * heat;

    uv.x += distortion;

    // Фон для демонстрации эффекта
    vec3 sky  = vec3(0.35, 0.65, 1.00);
    vec3 sand = vec3(0.92, 0.82, 0.55);

    float horizon = smoothstep(0.0, 0.65, uv.y);
    vec3 col = mix(sand, sky, horizon);

    // Небольшая полосатость для наглядности искажений
    float stripes = sin(uv.x * 40.0) * 0.03;
    col += stripes;

    fragColor = vec4(col, 1.0);
}