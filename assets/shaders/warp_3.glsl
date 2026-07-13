float hash(vec2 p)
{
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5);
}

float noise(vec2 p)
{
    vec2 i = floor(p);
    vec2 f = fract(p);

    // Smooth interpolation
    f = f * f * (3.0 - 2.0 * f);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    return mix(
        mix(a, b, f.x),
        mix(c, d, f.x),
        f.y
    );
}

float fbm(vec2 p)
{
    float value = 0.0;
    float strength = 0.5;

    for (int i = 0; i < 4; i++)
    {
        value += noise(p) * strength;

        p = p * 2.0 + vec2(2.0, 1.5);
        strength *= 0.5;
    }

    return value;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = (
        fragCoord - 0.5 * iResolution.xy
    ) / iResolution.y;

    float time = iTime * 0.08;

    vec2 p = uv * 3.0;

    // Create a large flowing distortion
    float warp = fbm(
        p * 0.8 + vec2(0.0, time)
    );

    p.x += (warp - 0.5) * 1.4;

    // Create large erosion channels
    float largeFlow = fbm(
        p * vec2(3.0, 0.7)
    );

    largeFlow =
        1.0 - abs(largeFlow * 2.0 - 1.0);

    largeFlow = pow(largeFlow, 5.0);

    // Create smaller branching details
    float smallFlow = fbm(
        p * vec2(7.0, 1.4) + 3.0
    );

    smallFlow =
        1.0 - abs(smallFlow * 2.0 - 1.0);

    smallFlow = pow(smallFlow, 8.0);

    // Combine the large and small channels
    float flow =
        largeFlow + smallFlow * 0.35;

    // Increase the contrast
    flow = smoothstep(
        0.22,
        0.95,
        flow
    );

    // White ground with dark erosion channels
    float color = 1.0 - flow;

    fragColor = vec4(vec3(color), 1.0);
}