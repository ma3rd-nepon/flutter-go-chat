float hash(float n)
{
    return fract(sin(n * 127.1) * 43758.5453123);
}

vec2 fireflyPos(float id, float t)
{
    float phase1 = hash(id + 1.0) * 6.2831853;
    float phase2 = hash(id + 2.0) * 6.2831853;
    float phase3 = hash(id + 3.0) * 6.2831853;

    vec2 base = vec2(
        hash(id * 17.0),
        hash(id * 31.0)
    );

    vec2 p = base;

    // общий ветер
    p.x += sin(t * 0.15) * 0.06;

    // плавное блуждание
    p.x += sin(t * 0.55 + phase1) * 0.10;
    p.y += cos(t * 0.65 + phase2) * 0.08;

    // мелкая хаотичность
    p.x += sin(t * 1.60 + phase3) * 0.025;
    p.y += cos(t * 1.30 + phase1) * 0.020;

    // отражение от краёв
    p = abs(fract(p * 0.5) * 2.0 - 1.0);

    return p;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;

    vec3 color = vec3(0.0);
    float alpha = 0.0;

    const int COUNT = 50;

    for(int i = 0; i < COUNT; i++)
    {
        float fi = float(i);

        vec2 pos = fireflyPos(fi, iTime);

        float dist = length(uv - pos);

        // размер как у снежинок
        float size = mix(
            0.001,
            0.0035,
            hash(fi + 10.0)
        );

        // индивидуальное мерцание
        float pulse =
            0.5 +
            0.5 *
            sin(
                iTime *
                mix(
                    1.0,
                    3.0,
                    hash(fi + 20.0)
                )
                +
                hash(fi + 30.0) * 6.2831853
            );

        // уменьшенное свечение
        float glow =
            exp(
                -dist * dist /
                (size * 2.5)
            );

        // яркое ядро
        float core =
            smoothstep(
                size,
                0.0,
                dist
            );

        float intensity =
            (glow * 0.25 + core)
            *
            mix(
                0.4,
                1.0,
                pulse
            );

        // белый или жёлтый
        vec3 flyColor =
            mix(
                vec3(1.0, 0.95, 0.55),
                vec3(1.0),
                step(
                    0.5,
                    hash(fi + 40.0)
                )
            );

        color += flyColor * intensity;
        alpha += intensity;
    }

    alpha = clamp(alpha, 0.0, 1.0);

    fragColor = vec4(color, alpha);
}