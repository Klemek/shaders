#version 150

out vec4 fragColor;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

uniform vec2 iResolution;
uniform float iTime;
uniform vec3 spectrum1;
uniform sampler2D midi1;
uniform sampler2D texture1;

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

vec2 cmod(vec2 uv, float m) {
    return mod(uv + m * .5, m) - m * .5;
}

mat2 rot(float angle) {
    return mat2(
        cos(angle * 2. * PI), -sin(angle * 2. * PI),
        sin(angle * 2. * PI), cos(angle * 2. * PI)
    );
}

vec2 move(vec2 uv, float speed, float range) {
    return uv + sin(iTime * speed) * range;
}

vec2 pan(vec2 uv, float zoom, float m) {
    return cmod(uv * zoom, m);
}

float circ(vec2 uv, vec2 c, float size) {
    return smoothstep(abs(size), length(uv - c), E);
}

float hcirc(vec2 uv, vec2 c, float size1, float size2) {
    return clamp(circ(uv, c, max(size1, size2)) - circ(uv, c, min(size1, size2)), 0, 1);
}

vec3 col(float x) {
    return vec3(
        .5 * (sin(x * 2. * PI) + 1.),
        .5 * (sin(x * 2. * PI + 2 * PI / 3) + 1.),
        .5 * (sin(x * 2. * PI - 2 * PI / 3) + 1.)
    );
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv0 = (fragCoord.xy) / iResolution.xy;
    vec2 uv1 = (uv0 - .5) * vec2(iResolution.x / iResolution.y, 1);
    vec2 uv = uv1;
    //B11 / P1 - rotation
    uv = mix(uv, uv * rot(iTime * P1), vec2(B11));
    //B12 / F1 - movement
    uv = mix(uv, uv + sin(iTime * F1 * 2), vec2(B12));
    //B51 / F6 - wobble
    float d = mix(1, mix(1, sin(iTime * F6 * 10), F5) ,B51);
    // B21 / F2 - zoom1 + P2 - shape1
    uv = mix(uv, cmod(uv * 20 * F2 * d, 10 * P2), vec2(B21));
    // B22 - mirror
    uv = mix(uv, abs(uv), vec2(B22));
    // B23 - bending
    uv = mix(uv, uv * vec2(cos(uv.x) - sin(uv.y), cos(uv.x) - sin(uv.y)), vec2(B23));
    // B81 / P8 - fractal
    uv = mix (uv, uv * length(uv * 20 * P8), vec2(B81));
    // B31 / F3 - wave
    uv = mix(uv, uv + iTime * F3, vec2(B31));
    // B41 / F4 - zoom2 + P4 - shape2
    uv = mix(uv, cmod(uv * F4, 2 * P4), vec2(B41));
    // P5 - color1
    // P6 - color2
    // P7 - color speed
    // F7 - color shift from center
    float cd = iTime * P7 + length(uv1) * F7;
    vec3 c = vec3(col(P5 + cd));
    c = mix(c,  col(P6 + cd), smoothstep(E, -E, uv.x - uv.y));
    // F8 - echo
    c = mix(c, texture(texture1, uv0).xyz, F8);
    fragColor = vec4(c,1.0);
}
