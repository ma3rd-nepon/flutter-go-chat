// Minimal Snow
// ShaderToy

float hash(float n)
{
    return fract(sin(n) * 43758.5453123);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 col = vec3(0.0);

    const float COUNT = 80.0;

    for(float i = 0.0; i < COUNT; i++)
    {
        float seed = i;

        float x0     = hash(seed);
        float size   = mix(0.0015, 0.008, hash(seed + 1.3));
        float alpha  = mix(0.2, 1.0, hash(seed + 2.7));
        float speed  = mix(0.08, 0.25, hash(seed + 3.9));
        float phase  = hash(seed + 5.1) * 6.28318;

        float y = 1.0 - mod(iTime * speed + hash(seed + 7.2), 1.1);

        float wind = sin(iTime * 0.35) * 0.03;

        float sway = sin(iTime * 1.5 + phase) * 0.025;

        float x = x0 + wind + sway;

        vec2 p = uv - vec2(x, y);

        float d = length(p);

        float snow = smoothstep(size, size * 0.2, d);

        col += vec3(snow * alpha);
    }

    col = min(col, 1.0);

    fragColor = vec4(col, 0);
}