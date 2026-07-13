#define PI 3.14159267 

float random(vec2 p)
{
    return fract(
        sin(dot(p, vec2(12.9498,78.2353)))
        * 437588.5453
    );
}

float noise(vec2 p, float scale) {
    vec2 cell = floor(p * scale);
    vec2 local = fract(p * scale);
    local = local * local * (3. - 2. * local);
    vec4 randoms = vec4(random(cell),random(cell+vec2(1.0, 0.0)),random(cell+vec2(0.0, 1.0)),random(cell+vec2(1.0, 1.0)));

    return mix(mix(randoms.r, randoms.g, local.x), mix(randoms.b, randoms.a, local.x), local.y);
}

float fbm(vec2 p) {
    float value = 0.0;

    float scale = 4.0;
    float amp = 1.0;

    for(int i=0;i<5;i++) {
        value += noise(p, scale) * amp;

        scale *= 2.0;
        amp *= 0.5;
    }

    return value;
}

vec2 warp(vec2 p) {
    vec2 q;

    q.x = fbm(p);
    q.y = fbm(p + vec2(5.2, 1.3));

    p += q * 0.1;

    return p;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;

    uv = warp(uv);
    uv = warp(uv);
    uv = warp(uv);

    vec2 grid = floor(uv * 20.);
    float check = mod(grid.x + grid.y, 2.);

    float r = fbm(uv + iTime);
    float g = fbm(warp(uv) + iTime);
    float b = fbm(uv + iTime * 2.);


    vec3 color = vec3(r, g, b);
    
    fragColor = vec4(color, 1.0);
}