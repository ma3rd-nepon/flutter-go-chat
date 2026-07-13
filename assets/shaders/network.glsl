#define PARTICLES 25

float hash(float n)
{
    return fract(sin(n) * 43758.5453123);
}

vec2 particlePos(float id, float t)
{
    vec2 start = vec2(
        hash(id * 13.17),
        hash(id * 71.91)
    );

    vec2 vel = vec2(
        hash(id * 91.73) - 0.5,
        hash(id * 27.64) - 0.5
    );

    vel *= 0.15;

    vec2 p = start + vel * t;

    // отражение от краёв
    p = abs(fract(p * 0.5) * 2.0 - 1.0);

    return p;
}

float lineSegment(vec2 uv, vec2 a, vec2 b)
{
    vec2 pa = uv - a;
    vec2 ba = b - a;

    float h = clamp(
        dot(pa, ba) / dot(ba, ba),
        0.0,
        1.0
    );

    float d = length(pa - ba * h);

    return smoothstep(
        0.003,
        0.0,
        d
    );
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;

    float particles = 0.0;
    float lines = 0.0;

    vec2 pos[PARTICLES];

    for(int i = 0; i < PARTICLES; i++)
    {
        pos[i] = particlePos(float(i), iTime);
    }

    // точки
    for(int i = 0; i < PARTICLES; i++)
    {
        float d = length(uv - pos[i]);

        particles += smoothstep(
            0.01,
            0.0,
            d
        );
    }

    // линии
    for(int i = 0; i < PARTICLES; i++)
    {
        int connections = 0;

        for(int j = i + 1; j < PARTICLES; j++)
        {
            float dist = distance(
                pos[i],
                pos[j]
            );

            if(dist < 0.18 && connections < 3)
            {
                float fade =
                    1.0 - dist / 0.18;

                lines +=
                    lineSegment(
                        uv,
                        pos[i],
                        pos[j]
                    ) * fade * 0.5;

                connections++;
            }
        }
    }

    float alpha =
        clamp(
            particles +
            lines,
            0.0,
            1.0
        );

    fragColor = vec4(
        vec3(alpha),
        alpha
    );
}