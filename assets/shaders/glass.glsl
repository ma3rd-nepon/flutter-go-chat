#iChannel0 "https://i.imgur.com/Tcgw968.jpeg"

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;

    vec2 center = vec2(0.5, 0.5);
    float radius = 0.25;

    vec2 d = uv - center;
    float dist = length(d);

    vec2 sampleUV = uv;

    if(dist < radius)
    {
        float t = dist / radius;

        // Сильная выпуклость
        float lens = (1.0 - t * t);

        sampleUV -= d * lens * 0.35;
    }

    vec3 col = texture(iChannel0, sampleUV).rgb;

    // Блик
    float highlight =
        pow(
            1.0 - clamp(dist / radius, 0.0, 1.0),
            4.0
        );

    col += highlight * 0.08;

    // Яркая стеклянная кромка
    float rim =
        smoothstep(
            radius,
            radius - 0.02,
            dist
        ) *
        (1.0 - smoothstep(
            radius - 0.03,
            radius - 0.06,
            dist
        ));

    col += rim * 0.4;

    fragColor = vec4(col, 1.0);
}