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
    
    //B83 - mirror
    uv = mix(uv, abs(uv), vec2(B83));
    
    // B81 / P8 movement speed / F8 movement range
    uv = mix(uv, move(uv, P8, F8), vec2(B81));
    
    // B71 / F7 - zoom / P7 - shape
    uv = mix(uv, pan(uv, F7 * 20, P7 * 10), vec2(B71));
    
    // P1 - base color
    // F1 - color spread
    // B11 / B12 / B13 - B&W
    // F2 - colorspeed
    // B21 / P2 - colorsteps (1 - 10)
    float cd = F2 * iTime;
    cd = mix(cd, floor(cd * P2 * 10) / max(P2 * 10, 1), B21);
    vec3 c0 = mix(vec3(0), col(P1 + cd), vec3(B11));
    vec3 c1 = mix(vec3(1), col(P1 + cd + F1 * .5), vec3(B12));
    vec3 c2 = mix(vec3(0), col(P1 + cd - F1 * .5), vec3(B13));
    
    vec3 c = c0;
    
    // F6 - distance related distort
    float d = length(uv1) * F6;
    
    // P3 -> P4 -> P5 circles
    // F3 inner circle speed
    // F4 outer circle speed
    c = mix(c, c1, hcirc(uv, vec2(.0), P4 + .1 * sin(iTime * F3 * 10) + d, P5 + .1 * sin(iTime * F4 * 10) - d));
    c = mix(c, c2, hcirc(uv, vec2(.0), P3 + .1 * sin(iTime * F3 * 10) - d, P4 + .1 * sin(iTime * F4 * 10) + d));
    
    fragColor = vec4(c,1.0);
}
