#version 150

out vec4 fragColor;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

uniform vec2 iResolution;
uniform float iTime;

void mainImage(out vec4, in vec2);
void main(void) { mainImage(fragColor,gl_FragCoord.xy); }


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#define PI 3.14159
#define E .0001

float rand(float seed){
    float v=pow(abs(seed),6./7.);
    v*=sin(v)+1.;
    return fract(v);
}

mat2 rot(float angle){
    return mat2(
        cos(angle*2.*PI),-sin(angle*2.*PI),
        sin(angle*2.*PI),cos(angle*2.*PI)
    );
}

vec3 col(float x){
    return vec3(
        .5*(sin(x*2.*PI)+1.),
        .5*(sin(x*2.*PI+2.*PI/3.)+1.),
        .5*(sin(x*2.*PI-2.*PI/3.)+1.)
    );
}

float perlin_dg(vec2 uv, vec2 grid){
    vec2 g = vec2(1, 0) * rot(rand(grid.x + grid.y * 4529));
    vec2 d = uv - grid;
    return dot(d, g);
}

float interpolate(float a0, float a1, float w){
    return (a1 - a0) * ((w * (w * 6.0 - 15.0) + 10.0) * w * w * w) + a0;
}

float perlin(vec2 uv0){
    vec2 grid = vec2(int(uv0.x), int(uv0.y));
    float dg_00 = perlin_dg(uv0, grid + vec2(0, 0));
    float dg_01 = perlin_dg(uv0, grid + vec2(0, 1));
    float dg_10 = perlin_dg(uv0, grid + vec2(1, 0));
    float dg_11 = perlin_dg(uv0, grid + vec2(1, 1));
    vec2 uv = mod(uv0, 1);
    return interpolate(interpolate(dg_00, dg_10, uv.x), interpolate(dg_01, dg_11, uv.x), uv.y);
}

#define ZOOM 5

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv0 = (fragCoord.xy) / iResolution.xy;
    vec2 uv = (uv0) * vec2(iResolution.x / iResolution.y, 1);

    float p = perlin(uv * ZOOM) + perlin(uv * ZOOM * 5 + vec2(0, iTime)) + perlin(uv * ZOOM * 10);

    vec3 c = col(p);
    
    fragColor = vec4(c, 1);
}
