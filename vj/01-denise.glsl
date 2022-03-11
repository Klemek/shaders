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

#define B00 midi(11, 13)
#define B01 midi(8, 13)
#define B02 midi(9, 13)
#define B03 midi(7, 13)
#define B04 midi(6, 13)
#define B05 midi(10, 13)

float preset(float v0, float v1, float v2, float v3, float v4, float v5) {
    float v = v0;
    v = mix(v, v1, B01);
    v = mix(v, v2, B02);
    v = mix(v, v3, B03);
    v = mix(v, v4, B04);
    v = mix(v, v5, B05);
    return v;
}

#define F1  preset(midi(29, 11), 0.50, 0.00, 0.00, 0.00, 0.00)
#define P1  preset(midi(13, 12), 0.25, 0.00, 0.00, 0.00, 0.00)
#define B11 preset(midi(29, 12), 1.00, 0.00, 0.00, 0.00, 0.00)
#define B12 preset(midi(13, 13), 1.00, 0.00, 0.00, 0.00, 0.00)
#define B13 preset(midi(29, 13), 1.00, 0.00, 0.00, 0.00, 0.00)

#define F2  preset(midi(30, 11), 0.00, 0.00, 0.00, 0.00, 0.00)
#define P2  preset(midi(14, 12), 0.00, 0.00, 0.00, 0.00, 0.00)
#define B21 preset(midi(30, 12), 0.00, 0.00, 0.00, 0.00, 0.00)
#define B22 preset(midi(14, 13), 0.00, 0.00, 0.00, 0.00, 0.00)
#define B23 preset(midi(30, 13), 0.00, 0.00, 0.00, 0.00, 0.00)

#define F3  preset(midi(31, 11), 0.25, 0.00, 0.00, 0.00, 0.00)
#define P3  preset(midi(15, 12), 0.05, 0.00, 0.00, 0.00, 0.00)
#define B31 preset(midi(31, 12), 0.00, 0.00, 0.00, 0.00, 0.00)
#define B32 preset(midi(15, 13), 0.00, 0.00, 0.00, 0.00, 0.00)
#define B33 preset(midi(31, 13), 0.00, 0.00, 0.00, 0.00, 0.00)

#define F4  preset(midi(00, 12), 0.33, 0.00, 0.00, 0.00, 0.00)
#define P4  preset(midi(16, 12), 0.20, 0.00, 0.00, 0.00, 0.00)
#define B41 preset(midi(00, 13), 0.00, 0.00, 0.00, 0.00, 0.00)
#define B42 preset(midi(16, 13), 0.00, 0.00, 0.00, 0.00, 0.00)
#define B43 preset(midi(00, 14), 0.00, 0.00, 0.00, 0.00, 0.00)

#define F5  preset(midi(01, 12), 0.33, 0.00, 0.00, 0.00, 0.00)
#define P5  preset(midi(17, 12), 0.33, 0.00, 0.00, 0.00, 0.00)
#define B51 preset(midi(01, 13), 0.00, 0.00, 0.00, 0.00, 0.00)
#define B52 preset(midi(17, 13), 0.00, 0.00, 0.00, 0.00, 0.00)
#define B53 preset(midi(01, 14), 0.00, 0.00, 0.00, 0.00, 0.00)

#define F6  preset(midi(02, 12), 0.05, 0.00, 0.00, 0.00, 0.00)
#define P6  preset(midi(18, 12), 0.05, 0.00, 0.00, 0.00, 0.00)
#define B61 preset(midi(02, 13), 1.00, 0.00, 0.00, 0.00, 0.00)
#define B62 preset(midi(18, 13), 0.00, 0.00, 0.00, 0.00, 0.00)
#define B63 preset(midi(02, 14), 0.00, 0.00, 0.00, 0.00, 0.00)

#define F7  preset(midi(03, 12), 0.00, 0.00, 0.00, 0.00, 0.00)
#define P7  preset(midi(19, 12), 0.00, 0.00, 0.00, 0.00, 0.00)
#define B71 preset(midi(03, 13), 0.00, 0.00, 0.00, 0.00, 0.00)
#define B72 preset(midi(19, 13), 0.00, 0.00, 0.00, 0.00, 0.00)
#define B73 preset(midi(03, 14), 0.00, 0.00, 0.00, 0.00, 0.00)

#define F8  preset(midi(04, 12), 0.00, 0.00, 0.00, 0.00, 0.00)
#define P8  preset(midi(20, 12), 0.00, 0.00, 0.00, 0.00, 0.00) 
#define B81 preset(midi(04, 13), 0.00, 0.00, 0.00, 0.00, 0.00)
#define B82 preset(midi(20, 13), 0.00, 0.00, 0.00, 0.00, 0.00)
#define B83 preset(midi(04, 14), 0.00, 0.00, 0.00, 0.00, 0.00)

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

float rect(vec2 uv, vec2 c, vec2 size) {
    uv -= c;
    return smoothstep(size.x + E, size.x - E, abs(uv.x)) * smoothstep(size.y + E, size.y - E, abs(uv.y));
}

float hcirc(vec2 uv, vec2 c, float size1, float size2) {
    return clamp(circ(uv, c, max(size1, size2)) - circ(uv, c, min(size1, size2)), 0, 1);
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

#define LT .002

float layout_fader(vec2 uv, float v) {
    return clamp(rect(uv, vec2(0, .1 * (v - 1)), vec2(.02, .1 * v)) + rect(uv, vec2(0), vec2(.02, .1)) - rect(uv, vec2(0), vec2(.02 - LT, .1 - LT)), 0, 1);
}

float layout_button(vec2 uv, float v) {
    return clamp(rect(uv, vec2(0), vec2(.02)) - rect(uv, vec2(0), vec2(.02 - LT) * (1 - v)), 0, 1);
}

float layout_pot(vec2 uv, float v) {
    return clamp(rect(uv, vec2(.055 * (v - 1), 0), vec2(.055 * v, .02)) + rect(uv, vec2(0), vec2(.055, .02)) - rect(uv, vec2(0), vec2(.055 - LT, .02 - LT)), 0, 1);
}

float layout_block(vec2 uv, float f, float p, float b1, float b2, float b3) {
    float d = 0;
    d += clamp(layout_fader(uv - vec2(.0, .0), f), 0, 1);
    d += clamp(layout_button(uv - vec2(-.07, .08), b1), 0, 1);
    d += clamp(layout_button(uv - vec2(-.07, 0), b2), 0, 1);
    d += clamp(layout_button(uv - vec2(-.07, -.08), b3), 0, 1);
    d += clamp(layout_pot(uv - vec2(-.035, .15), p), 0, 1);
    return d;
}

float show_layout(vec2 uv) {
    float d = 0;
    uv.x += .47;d += layout_block(uv, F1, P1, B11, B12, B13);
    uv.x -= .15;d += layout_block(uv, F2, P2, B21, B22, B23);
    uv.x -= .15;d += layout_block(uv, F3, P3, B31, B32, B33);
    uv.x -= .15;d += layout_block(uv, F4, P4, B41, B42, B43);
    uv.x -= .15;d += layout_block(uv, F5, P5, B51, B52, B53);
    uv.x -= .15;d += layout_block(uv, F6, P6, B61, B62, B63);
    uv.x -= .15;d += layout_block(uv, F7, P7, B71, B72, B73);
    uv.x -= .15;d += layout_block(uv, F8, P8, B81, B82, B83);
    return d;
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv0 = (fragCoord.xy) / iResolution.xy;
    vec2 uv1 = (uv0 - .5) * vec2(iResolution.x / iResolution.y, 1);
    vec2 uv = uv1;
    // B73 - mirror
    uv = mix(uv, abs(uv), vec2(B73));   
    // B71 / P7 movement speed / F7 movement range
    uv = mix(uv, move(uv, P7, F7), vec2(B71));
    // B61 / P6 - zoom / F6 - shape
    uv = mix(uv, pan(uv, P6 * 20, F6 * 10), vec2(B61));
    // P1 - base color / F1 - Color spread
    // B11 / B12 / B13 - Activate color (B/W/B)
    // B21 - P2 - Color Speed
    // B22 / F2 - Color steps (2 - 10)
    // B23 - Keep same colors
    float cd = mix(0, mod(P2 * iTime * 2, 1), B21);
    float steps = floor(F2 * 8 + 2);
    cd = mix(cd, floor(cd * steps) / steps, B22);
    vec3 c0 = mix(vec3(0), col(P1 + mix(cd, .333 + sin2(cd) * F1 * .333, B23)), vec3(B11));
    vec3 c1 = mix(vec3(.5), col(P1 + mix(cd + F1 * .333, .333 + sin2(cd + .333) * F1 * .333, B23)), vec3(B12));
    vec3 c2 = mix(vec3(1), col(P1 + mix(cd + F1 * .667, .333 + sin2(cd + .667) * F1 * .333, B23)), vec3(B13));
    vec3 c = c0;
    // P3 -> P4 -> P5 - circles
    // F3 - inner circle speed
    // F4 - outer circle speed
    // F5 - distance related distort
    float d = length(uv1) * F5;
    c = mix(c, c2, hcirc(uv, vec2(.0), P4 + .1 * sin(iTime * F4 * 10) + d, P5 + .1 * sin(iTime * F3 * 10) - d));
    c = mix(c, c1, hcirc(uv, vec2(.0), P3 + .1 * sin(iTime * F3 * 10) - d, P4 + .1 * sin(iTime * F4 * 10) + d));
    // B82 - logo / B83 - invert logo
//    c = mix(c, mix(vec3(1), 1 - c, vec3(B83)), vec3(B82) * (1 - texture(video1, uv1 + .5).xyz));
    c = mix(c, mix(vec3(1), 1 - c, vec3(B83)), vec3(B82) * texture(image1, uv1 + .5).xyz);
    // P8 / F8 - feedback
    // B81 - invert feedback zoom
    c = mix(c, texture(frame1, (uv0 - .5) * mix(1 - F8 * spectrum1.x, 1 + F8 * spectrum1.x, B81) + .5).xyz, P8);
    
    c = mix(c, vec3(1), show_layout(uv1) * B00);
    
    fragColor = vec4(c,1.0);
}
