#version 150

out vec4 fragColor;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

uniform vec2 iResolution;
uniform float iTime;
uniform float iTimeDelta;
uniform int iFrame;
uniform vec4 iMouse;
uniform sampler2D iChannel0;
uniform sampler2D iChannel1;
uniform sampler2D iChannel2;
uniform sampler2D iChannel3;
uniform vec4 iDate;
uniform float iSampleRate;
uniform vec3 spectrum2;
uniform sampler2D midi1;

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

void mainImage(out vec4, in vec2);
void main(void) { mainImage(fragColor,gl_FragCoord.xy); }


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#define PI 3.14159
#define BPM 240
#define E .001

float tbpm(float f) {
    return iTime * f * BPM / 60;
}

float sinbpm(float f, float d) {
    return sin(tbpm(f) * PI + d * PI);
}

vec2 cmod(vec2 uv, float m) {
    return mod(uv + m * .5, m) - m * .5;
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

vec3 mask(vec3 c, float m, vec3 c2) {
    return clamp(c * (1 - m) + m * c2, 0, 1);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = (fragCoord.xy) / iResolution.xy - .5;
    uv.x *= iResolution.x / iResolution.y;
    
    uv = abs(uv);
    
    uv *= P4 * 10;
    
    vec2 uv1 = uv + tbpm(F4);
    
    vec2 uv2 = cmod(uv1, P5);
    
    float d = length(uv) * F5 * .1;   
    
    vec3 c = F3 * col(tbpm(P6) + F6);// * ((1. - P1) + spectrum2.z * P1);
    vec3 col1 = F2 * col(tbpm(P6) + F6 - P7);// * ((1. - P2) + spectrum2.y * P2);
    vec3 col2 = F1 * col(tbpm(P6)  + F6 + P7);// * ((1. - P3) + spectrum2.x * P3);
    
    c = mask(c, hcirc(uv2, vec2(.0), P2 * P5 + P8 * .1 * sinbpm(F7, 0) + d , P3 * P5 + P8 * .1 * sinbpm(F8, 0) - d), col1);
    
    c = mask(c, hcirc(uv2, vec2(.0), P1 * P5 + P8 * .1 * sinbpm(F7, 1) - d, P2 * P5 + P8 * .1 * sinbpm(F8, 1) + d), col2);
    
    fragColor = vec4(c,1.0);
}
