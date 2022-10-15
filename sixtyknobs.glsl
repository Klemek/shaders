#version 150

out vec4 fragColor;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

uniform vec2 iResolution;
uniform float iTime;
uniform vec3 spectrum1;
uniform sampler2D midi1;
uniform sampler2D frame1;
uniform sampler2D video1;
uniform sampler2D image1;
uniform vec4 color1;
uniform vec4 color2;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

float midi(float x, float y) {
    return texture(midi1, vec2(x/32., y/32.)).x;
}

float sk(float x, float y) {
    float v = (y - 1) * 6 + (x - 1);
    float mx = mod(30 + v, 32);
    float my = 11 + ((30 + v) - mx) / 32;
    return midi(mx, my);
}

#define butt(vb, v1, v0) ((vb) > .01 ? (v1) : (v0))


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

void mainImage(out vec4, in vec2);
void main(void) { mainImage(fragColor,gl_FragCoord.xy); }

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#define PI 3.14159
#define E .0001

#define VIDEO_W 1280
#define VIDEO_H 720
#define IMAGE_W 1
#define IMAGE_H 1

// BASIC

float cmod(float x, float m) {
    return mod(x + m * .5, m) - m * .5;
}

vec2 cmod2(vec2 uv, float m) {
    return mod(uv + m * .5, m) - m * .5;
}

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

float chainsaw(float x){
    return mod(x, 1) * step(1, mod(x - 1, 2)) + mod(-x, 1) * step(1, mod(x, 2));
}

// SHAPES

float rect(vec2 uv, vec2 c, vec2 size) {
    uv -= c;
    return smoothstep(size.x + E, size.x - E, abs(uv.x)) * smoothstep(size.y + E, size.y - E, abs(uv.y));
}

// LAYERS

vec2 lens(vec2 uv, float limit, float power) {
    return uv * (limit - length(uv * power));
}

vec2 pan(vec2 uv, float zoom, float m) {
    return cmod2(uv * zoom, m + E);
}

vec2 kal(vec2 uv, int n) {
    vec2 uvp = vec2(
        length(uv),
        atan(uv.y, uv.x)
    );
    uvp.y = abs(mod(uvp.y + PI / (2 * n), PI / n) - PI / (2 * n));
    return vec2(
        uvp.x * cos(uvp.y),
        uvp.x * sin(uvp.y)
    );
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv0 = (fragCoord.xy) / iResolution.xy;
    vec2 uv1 = (uv0 - .5) * vec2(iResolution.x / iResolution.y, 1);
//    
    uv1 = butt(sk(1, 2), kal(uv1, int(sk(1, 2) * 5)), uv1);
//    
    uv1 = butt(sk(1, 3), cmod2(uv1, sk(1, 3)), uv1);

    uv1 = butt(sk(1, 4), lens(uv1, sk(1, 4) * 2, sk(2, 4) * 2), uv1);
    
    uv1 *= sk(1, 5) * 3;
    
    uv1 *= rot(-iTime * sk(1, 6));
    
    uv1 += vec2(cos(iTime * sk(2, 7)), sin(iTime * sk(2, 7))) * sk(1, 7);
    
    uv1 = butt(sk(1, 8), kal(uv1, int(sk(1, 8) * 7)), uv1);
    
    uv1 *= rot(iTime * sk(1, 9) * .5);
    
    uv1 = mod(uv1 - iTime * sk(1, 10), sk(2, 10));
    
    float v2 = abs(sin(uv1.x)) * sk(3, 10) * 20 - 2 * sk(4, 10);
    
    vec3 c = vec3(sk(1, 1), sk(2, 1), sk(3, 1));
    
    c += vec3(
        sk(4, 1) * sin(iTime * sk(4, 2)),
        sk(5, 1) * sin(iTime * sk(5, 2)),
        sk(6, 1) * sin(iTime * sk(6, 2))
    );
    
    fragColor = vec4(c * v2,1.0);
}
