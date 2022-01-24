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


float midi(float x, float y) {
    return texture(midi1, vec2(x/32., y/32.)).x;
}

#define F1 midi(29, 11)
#define F2 midi(30, 11)
#define F3 midi(31, 11)
#define F4 midi(0, 12)
#define F5 midi(1, 12)
#define F6 midi(2, 12)
#define F7 midi(3, 12)
#define F8 midi(4, 12)
#define P1 midi(13, 12)
#define P2 midi(14, 12)
#define P3 midi(15, 12)
#define P4 midi(16, 12)
#define P5 midi(17, 12)
#define P6 midi(18, 12)
#define P7 midi(19, 12)
#define P8 midi(20, 12) 
#define B11 midi(29, 12)
#define B21 midi(30, 12)
#define B31 midi(31, 12)
#define B41 midi(0, 13)
#define B51 midi(1, 13)
#define B61 midi(2, 13)
#define B71 midi(3, 13)
#define B81 midi(4, 13)
#define B12 midi(13, 13)
#define B22 midi(14, 13)
#define B32 midi(15, 13)
#define B42 midi(16, 13)
#define B52 midi(17, 13)
#define B62 midi(18, 13)
#define B72 midi(19, 13)
#define B82 midi(20, 13)
#define B13 midi(29, 13)
#define B23 midi(30, 13)
#define B33 midi(31, 13)
#define B43 midi(0, 14)
#define B53 midi(1, 14)
#define B63 midi(2, 14)
#define B73 midi(3, 14)
#define B83 midi(4, 14)

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

vec3 col2(float x1, float x2, float x){
    return col(x1 + chainsaw(x) * (x2 - x1));
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#define TRAIL_HEIGHT .01

float trail(float x){
    return smoothstep(1, 0, x) * step(-1, -x);
}

float trails(vec2 uv){
    return clamp(
        trail(mod(uv.x, 5.351223)) +
        trail(mod(uv.x, 7.182638))
    , 0, 1);
}

vec2 spiral(vec2 uv, float k1, float k2, float delta) {
    float r = length(uv);
    float t = mod(atan(uv.y, uv.x) + delta, 2 * PI);
    return (t - vec2(0, log(r) / k1)) / (PI * vec2(k2, 2));
}

vec2 lens(vec2 uv, float limit, float power) {
    return uv * (limit - length(uv * power));
}

float circ(vec2 uv, vec2 c, float size) {
    return smoothstep(abs(size), length(uv - c), E);
}

vec2 pan(vec2 uv, float zoom, float m) {
    return cmod2(uv * zoom, m + E);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv0 = (fragCoord.xy) / iResolution.xy;
    vec2 uv1 = (uv0 - .5) * vec2(iResolution.x / iResolution.y, 1);
    
    vec2 uv = uv1;
    
    // B61 / P6 - zoom / F6 - shape
    uv = mix(uv, pan(uv, P6 * 2, F6), vec2(B61));
    // B42 - mirror
    // B41 / P4 - bend power / F4 - bend balance
    // B51 / F5 - shift power / P5 - shift speed
    uv = mix(uv, abs(uv), vec2(B42));
    uv = mix(uv, uv * 
        cos(uv.x * (P4 + (F4 - .5) + mix(0, sin(mod(iTime * P5, 1)), B51) * F5) * 10) +
        sin(uv.y * (P4 - (F4 - .5) + mix(0, sin(mod(iTime * P5, 1)), B51) * F5) * 10), vec2(B41));
    
    vec2 uv2 = spiral(uv, .2, .1, iTime);
    
    // F2 - Trail size
    uv2.x += 100 * rand(int(uv2.y/((F2 * .05 + .005))));
    float t = trails(uv2);
    
    // B31 / F3 - circle size / P3 circle width
    float c_size = .1 * F3;
    t = mix(t, (clamp(t + circ(uv, vec2(0), c_size), 0, 1) - circ(uv, vec2(0), c_size - P3 * .05)), B31);
    // P1 - base color / F1 - Color spread
    // B21 - P2 - Color Speed
    vec3 c = t * col2(P1, P1 + F1, uv2.x);
    // B82 - logo / B83 - invert logo
//    c = mix(c, mix(vec3(1), 1 - c, vec3(B83)), vec3(B82) * (1 - texture(video1, uv1 * .5 + .5).xyz));
    c = mix(c, mix(vec3(1), 1 - c, vec3(B83)), vec3(B82) * texture(image1, uv1 + .5).xyz);
    // P8 / F8 - feedback
    // B81 - invert feedback zoom
    c = mix(c, texture(frame1, (uv0 - .5) * mix(1 - F8 * spectrum1.x, 1 + F8 * spectrum1.x, B81) + .5).xyz, P8);
    fragColor = vec4(c,1.0);
}
