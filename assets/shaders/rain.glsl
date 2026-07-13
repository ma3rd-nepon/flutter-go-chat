float hash(vec2 p)
{
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;

    float rain = 0.0;

    // плотность сетки
    vec2 gridSize = vec2(70.0, 120.0);

    vec2 gridUV = uv * gridSize;

    vec2 cell = floor(gridUV);

    // угол дождя
    float angle = -0.25;

    vec2 dir = normalize(vec2(angle, -1.0));
    vec2 perp = vec2(-dir.y, dir.x);

    // проверяем соседние клетки
    for(int y = -1; y <= 1; y++)
    {
        for(int x = -1; x <= 1; x++)
        {
            vec2 c = cell + vec2(x, y);

            float rnd = hash(c);

            float speed  = mix(1.5, 3.5, hash(c + 1.0));
            float length = mix(0.03, 0.10, hash(c + 2.0));
            float width  = 0.015;
            float alpha  = mix(0.2, 1.0, hash(c + 3.0));

            // позиция капли внутри клетки
            vec2 local;

            local.x = hash(c + 4.0);

            float t = fract(
                hash(c + 5.0) +
                iTime * speed * 0.35
            );

            local.y = 1.0 - t;

            vec2 p = (c + local) / gridSize;

            vec2 d = uv - p;

            float along = dot(d, dir);
            float across = abs(dot(d, perp));

            float drop =
                smoothstep(width, 0.0, across) *
                step(0.0, along) *
                step(along, length);

            rain += drop * alpha;
        }
    }

    rain = clamp(rain, 0.0, 1.0);

    fragColor = vec4(vec3(rain), rain);
}