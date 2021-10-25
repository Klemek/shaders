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

vec2 cmod(vec2 uv, float m) {
    return mod(uv + m * .5, m) - m * .5;
}

float sin2(float x) {
    return sin(x * 2 * PI);
}

float cos2(float x) {
    return cos(x * 2 * PI);
}

mat2 rot(float angle) {
    return mat2(
        cos2(angle), -sin2(angle),
        sin2(angle), cos2(angle)
    );
}

vec3 col(float x) {
    return vec3(
        .5 * (sin2(x) + 1.),
        .5 * (sin2(x + .333) + 1.),
        .5 * (sin2(x - .333) + 1.)
    );
}

// SHAPES

float circ(vec2 uv, vec2 c, float size) {
    return smoothstep(abs(size), length(uv - c), E);
}

float hcirc(vec2 uv, vec2 c, float size1, float size2) {
    return clamp(circ(uv, c, max(size1, size2)) - circ(uv, c, min(size1, size2)), 0, 1);
}

float square(vec2 uv, vec2 c, float size) {
    uv -= c;
    return smoothstep(size + E, size - E, abs(uv.x + uv.y) + abs(uv.x - uv.y));
}

float hsquare(vec2 uv, vec2 c, float size1, float size2) {
    return clamp(square(uv, c, max(size1, size2) - square(uv, c, min(size1, size2))), 0, 1);
}

// LAYERS

vec2 move(vec2 uv, float speed, float range) {
    return uv + sin(iTime * speed) * range;
}

vec2 pan(vec2 uv, float zoom, float m) {
    return cmod(uv * zoom, m + E);
}

vec2 lens(vec2 uv, float limit, float power) {
    return uv * (limit - length(uv * power));
}

vec2 rotate(vec2 uv, float speed) {
    return uv * rot(iTime * speed);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv0 = (fragCoord.xy) / iResolution.xy;
    vec2 uv1 = (uv0 - .5) * vec2(iResolution.x / iResolution.y, 1);
    vec2 uv = uv1;
    // B71 / F7 - bend focal / P7 - bend power
    uv = mix(uv, lens(uv, F7, P7), vec2(B71));
    // B61 / P6 - zoom / F6 - shape
    uv = mix(uv, pan(uv, P6 * 2, F6), vec2(B61));
    // B42 - mirror
    // B41 / P4 - bend power / F4 - bend balance
    // B51 / F5 - shift power / P5 - shift speed
    uv = mix(uv, abs(uv), vec2(B42));
    uv = mix(uv, uv * 
        cos(uv.x * (P4 + (F4 - .5) + mix(0, sin2(mod(iTime * P5, 1)), B51) * F5) * 10) +
        sin(uv.y * (P4 - (F4 - .5) + mix(0, sin2(mod(iTime * P5, 1)), B51) * F5) * 10), vec2(B41));
    
    // P1 - base color / F1 - Color spread
    // B11 / B12 - Activate color (B/W) / B13 - invert BW
    // B21 - P2 - Color Speed
    // B22 / F2 - Color steps (2 - 10)
    // B23 - Keep same colors
    float cd = mix(0, mod(P2 * iTime * 2, 1), B21);
    float steps = floor(F2 * 8 + 2);
    cd = mix(cd, floor(cd * steps) / steps, B22);
    vec3 c0 = mix(vec3(mix(0, 1, B13)), col(P1 + mix(cd, .25 + sin2(cd - .25) * F1 * .5, B23)), vec3(B11));
    vec3 c1 = mix(vec3(mix(1, 0, B13)), col(P1 + mix(cd + F1 * .5, .25 + sin2(cd + .25) * F1 * .5, B23)), vec3(B12));
    // P3 - size / F3 - thickness
    vec3 c = mix(c0, c1, hsquare(uv, vec2(0), P3 - F3 * .5, P3 + F3 * .5));
    // B82 - logo / B83 - invert logo
    c = mix(c, mix(vec3(1), 1 - c, vec3(B83)), vec3(B82) * (1 - texture(video1, uv1 * .5 + .5).xyz));
//    c = mix(c, mix(vec3(1), 1 - c, vec3(B83)), vec3(B82) * texture(image1, uv1 + .5).xyz);
    // P8 / F8 - feedback
    // B81 - invert feedback zoom
    c = mix(c, texture(frame1, (uv0 - .5) * mix(1 - F8 * spectrum1.x, 1 + F8 * spectrum1.x, B81) + .5).xyz, P8);
    fragColor = vec4(c,1.0);
}
