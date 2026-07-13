float hash(float n)
{
    return fract(sin(n * 127.1) * 43758.5453123);
}

vec3 starColor(float id)
{
    float r = hash(id * 20.0);

    if(r < 0.2)
        return vec3(0.3, 0.8, 1.0); // blue

    if(r < 0.4)
        return vec3(0.7, 0.3, 1.0); // violet

    if(r < 0.6)
        return vec3(1.0, 0.9, 0.2); // yellow

    if(r < 0.8)
        return vec3(0.3, 1.0, 0.5); // green

    return vec3(1.0); // white
}


vec2 starPosition(float id, float t)
{
    float phase = hash(id + 1.0);

    // случайный угол падения
    float angle =
        mix(
            -0.7,
            0.7,
            hash(id + 2.0)
        );

    vec2 dir = normalize(
        vec2(angle, -1.0)
    );

    float speed =
        mix(
            0.15,
            0.5,
            hash(id + 3.0)
        );

    vec2 start = vec2(
        hash(id + 4.0),
        hash(id + 5.0)
    );

    vec2 p =
        start +
        dir *
        (
            t *
            speed +
            phase
        );

    // лёгкий ветер
    p.x += sin(t * 0.5 + id) * 0.03;

    return fract(p);
}


void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;

    vec3 color = vec3(0.0);
    float alpha = 0.0;

    const int COUNT = 120;

    for(int i = 0; i < COUNT; i++)
    {
        float fi = float(i);

        vec2 pos =
            starPosition(
                fi,
                iTime
            );

        float dist =
            length(
                uv - pos
            );


        float size =
            mix(
                0.001,
                0.003,
                hash(fi + 10.0)
            );


        // вспышки
        float pulse =
            0.5 +
            0.5 *
            sin(
                iTime *
                mix(
                    1.0,
                    5.0,
                    hash(fi + 20.0)
                )
                +
                hash(fi + 30.0) *
                6.28
            );


        float glow =
            exp(
                -dist * dist /
                (size * 4.0)
            );


        float core =
            smoothstep(
                size,
                0.0,
                dist
            );


        float brightness =
            (glow * 0.4 + core)
            *
            mix(
                0.2,
                1.0,
                pulse
            );


        vec3 c =
            starColor(fi);


        color += c * brightness;

        alpha += brightness;
    }


    alpha =
        clamp(
            alpha,
            0.0,
            1.0
        );


    fragColor =
        vec4(
            color,
            alpha
        );
}