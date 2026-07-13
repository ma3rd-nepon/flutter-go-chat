#define TAU 6.28318530718

float hash21(vec2 p){
    p = fract(p * vec2(123.34, 345.45));
    p += dot(p, p + 34.345);
    return fract(p.x * p.y);
}
vec2 hash22(vec2 p){
    vec3 a = fract(p.xyx * vec3(123.34, 234.34, 345.65));
    a += dot(a, a + 34.45);
    return fract(vec2(a.x * a.y, a.y * a.z));
}
float noise(vec2 p){
    vec2 i = floor(p), f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    float a = hash21(i+vec2(0,0)), b = hash21(i+vec2(1,0));
    float c = hash21(i+vec2(0,1)), d = hash21(i+vec2(1,1));
    return mix(mix(a,b,u.x), mix(c,d,u.x), u.y);
}
const mat2 rot = mat2(0.8, 0.6, -0.6, 0.8);
float fbm(vec2 p){
    float v = 0.0, a = 0.5;
    for(int i=0;i<5;i++){
        v += a * noise(p);
        p = rot * p * 2.0 + 0.03;
        a *= 0.5;
    }
    return v;
}
float fbm3(vec2 p){
    float v = 0.0, a = 0.5;
    for(int i=0;i<3;i++){
        v += a * noise(p);
        p = rot * p * 2.0 + 0.03;
        a *= 0.5;
    }
    return v;
}
vec2 cheapCurl(vec2 p, float t){
    float e = 0.15;
    float nx = noise(p + vec2(0.0, e) + t) - noise(p - vec2(0.0, e) + t);
    float ny = noise(p - vec2(e, 0.0) + t) - noise(p + vec2(e, 0.0) + t);
    return vec2(nx, ny);
}


float milkyWay(vec2 uv){
    vec2 p = uv - vec2(0.05, 0.34);
    float ang = 0.42;
    mat2 m = mat2(cos(ang), -sin(ang), sin(ang), cos(ang));
    p = m * p;
    float wobble = 0.06*fbm3(vec2(p.x*1.2, 7.0));
    float dist = p.y - wobble;
    float band = exp(-dist*dist*26.0);
    float grainTex = fbm3(vec2(p.x*6.0, p.y*10.0) + 20.0);
    band *= (0.55 + 0.75*grainTex);
    float lane = fbm3(vec2(p.x*3.0, p.y*4.0) + 50.0);
    float dust = smoothstep(0.40, 0.62, lane);
    band *= mix(0.25, 1.0, dust);
    float mainLane = smoothstep(0.05, 0.0, abs(dist - 0.02));
    band *= (1.0 - mainLane*0.6);
    return clamp(band, 0.0, 1.0);
}


vec3 brightStar(vec2 uv, vec2 pos, vec3 tint, float size){
    vec2 d = uv - pos;
    float r = length(d);
    float core = smoothstep(size, 0.0, r);
    float spike = 0.0;
    spike += smoothstep(size*5.0, 0.0, abs(d.y)) * smoothstep(size*0.8, 0.0, abs(d.x));
    spike += smoothstep(size*5.0, 0.0, abs(d.x)) * smoothstep(size*0.8, 0.0, abs(d.y));
    float tw = 0.85 + 0.15*sin(iTime*3.0);
    return tint * (core*1.2 + spike*0.35) * tw;
}


vec3 starField(vec2 uv){
    vec3 col = vec3(0.0);
    float mw = milkyWay(uv);
    for(float s=0.0; s<3.0; s++){
        float scale = 45.0 + s*70.0;
        vec2 gv = uv * scale;
        vec2 id = floor(gv);
        vec2 f = fract(gv) - 0.5;
        vec2 rnd = hash22(id + s*17.3);
        float bright = hash21(id + s*7.3);
        float thresh = 0.64 - mw*0.50;
        if(bright < thresh) continue;
        float d = length(f - (rnd-0.5)*0.7);
        float core = smoothstep(0.045, 0.0, d) * (1.3 + mw*1.0);
        float glowR = 0.006/(d*1.05 + 0.02);
        float glowG = 0.006/(d      + 0.02);
        float glowB = 0.006/(d*0.95 + 0.02);
        vec3 glow = vec3(glowR, glowG, glowB) * 0.45;
        float tw = 0.6 + 0.4*sin(iTime*2.5 + bright*TAU*12.0);
        vec3 tint = mix(vec3(0.7,0.82,1.0), vec3(1.0,0.9,0.75), hash21(id+s));
        col += (core*tint + glow) * tw * pow(bright, 1.8);
    }
    col += mw * vec3(0.5,0.55,0.8) * 0.12;
    col += brightStar(uv, vec2(-0.55, 0.32), vec3(0.85,0.9,1.0), 0.003);
    col += brightStar(uv, vec2( 0.42, 0.42), vec3(1.0,0.92,0.8), 0.0025);
    return col;
}


vec3 meteor(vec2 uv, float t){
    float period = 8.0;
    float id = floor(t/period);
    float lt = fract(t/period)*period;
    float dur = 1.2;
    if(lt > dur) return vec3(0.0);
    float prog = lt/dur;
    vec2 start = vec2(-0.2, 0.5) + (hash22(vec2(id,1.0))-0.5)*vec2(1.4,0.3);
    vec2 dir = normalize(vec2(1.0, -0.5));
    vec2 head = start + dir * prog * 1.3;
    vec2 pa = uv - head;
    float along = dot(pa, -dir);
    along = clamp(along, 0.0, 0.25);
    vec2 closest = head - dir*along;
    float dperp = length(uv - closest);
    float trail = smoothstep(0.004, 0.0, dperp) * smoothstep(0.25, 0.0, along);
    float head_glow = smoothstep(0.012, 0.0, length(uv-head));
    float fade = smoothstep(0.0,0.15,prog) * smoothstep(1.0,0.7,prog);
    return vec3(0.9,0.95,1.0) * (trail + head_glow) * fade;
}

vec3 sky(vec2 uv){
    float g = smoothstep(-0.5, 0.9, uv.y);
    vec3 col = mix(vec3(0.012,0.025,0.06), vec3(0.003,0.004,0.014), g);
    return col;
}


float auroraDensity(vec2 p, float t, vec2 warp){
    p += warp;
    float w = fbm3(vec2(p.x*1.2, p.y*0.4 + t*0.3));
    p.x += w * 0.5;
    float rays = fbm(vec2(p.x*4.0, p.y*0.6 + t*0.2));
    float fine = fbm3(vec2(p.x*9.0, p.y*1.0 - t*0.15));
    rays = rays*0.65 + fine*0.35;
    rays = pow(clamp(rays,0.0,1.0), 3.0);
    return rays;
}


vec3 renderAurora(vec2 uv, float t){
    vec3 col = vec3(0.0);
    float drift = sin(t*0.15)*0.5 + 0.5;
    vec2 warp = cheapCurl(uv*0.5, t*0.2) * 0.5;
    for(int i=0;i<3;i++){
        float fi = float(i);
        float depth = 1.0 - fi*0.15;
        vec2 p = uv;
        float stretch = 1.0 + fi*0.5;
        p.x = (p.x*stretch + fi*3.7) * (1.0+fi*0.25) + t*(0.1+fi*0.03);
        float base = -0.30 - fi*0.04
                   + 0.06*sin(p.x*0.8 + t*0.4)
                   + 0.03*sin(p.x*1.9 - t*0.25);
        float dy = uv.y - base;
        float profile = smoothstep(-0.02, 0.06, dy)
                      * exp(-max(dy,0.0)*4.1)
                      * smoothstep(0.62, 0.30, dy);
        float curtain = fbm3(vec2(p.x*1.6 + t*0.08, 4.0));
        curtain = smoothstep(0.30, 0.62, curtain);
        float d = auroraDensity(p, t + fi*5.0, warp);
        float intensity = d * profile * curtain;
        float h = clamp(dy*2.0, 0.0, 1.0);
        vec3 c = mix(vec3(0.10,0.85,0.45), vec3(0.18,0.6,1.0), h);
        c = mix(c, vec3(0.55,0.3,1.0), smoothstep(0.5,1.0,h));
        c = mix(c, vec3(0.9,0.4,0.85), drift*0.2*smoothstep(0.5,1.0,h));
        float redEdge = smoothstep(0.8,1.0,h) * smoothstep(0.45,0.8,d);
        c += vec3(0.6,0.05,0.15) * redEdge * 0.6;
        col += c * intensity * 1.35 * depth;
    }
    return col;
}


float ridge(float x, float seed, float scale, float h){
    float n = fbm3(vec2(x*scale + seed, seed));
    float n2 = fbm3(vec2(x*scale*2.5 + seed, seed+5.0))*0.4;
    return (n + n2) * h;
}
vec2 mountains(vec2 uv){
    float h1 = -0.28 + ridge(uv.x, 3.0, 1.5, 0.14);
    float h2 = -0.36 + ridge(uv.x, 9.0, 2.2, 0.18);
    float horizon = max(h1, h2);
    float mask = smoothstep(0.004, -0.004, uv.y - horizon);
    float glow = smoothstep(0.07, 0.0, abs(uv.y - horizon));
    return vec2(mask, glow);
}

void mainImage(out vec4 O, in vec2 I){
    vec2 uv = (I - 0.5*iResolution.xy)/iResolution.y;
    uv.y += 0.22;
    float t = iTime * 0.3;

    vec3 col = sky(uv);
    col += starField(uv) * smoothstep(-0.25, 0.15, uv.y);
    col += meteor(uv, iTime) * smoothstep(-0.1, 0.2, uv.y);
    col += renderAurora(uv, t);
    col += vec3(0.03,0.11,0.09) * exp(-abs(uv.y+0.30)*5.0) * 0.6;

    vec2 mtn = mountains(uv);
    col = mix(col, vec3(0.003,0.005,0.013), mtn.x);
    col += vec3(0.10,0.35,0.32) * mtn.y * (1.0-mtn.x) * 0.35;

    vec2 ca = uv * 0.0025;
    col.r *= 1.0 + ca.x;
    col.b *= 1.0 - ca.x;
    vec2 q = I/iResolution.xy;
    col *= pow(16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y), 0.22);
    col = (col*(2.51*col+0.03))/(col*(2.43*col+0.59)+0.14);
    col = pow(clamp(col,0.0,1.0), vec3(0.4545));
    float grain = hash21(I + fract(iTime)*100.0) - 0.5;
    col += grain * 0.03;

    O = vec4(clamp(col,0.0,1.0), 1.0);
}