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

#define PRESETS false

#define B00 midi(11, 13)
#define B01 midi(8, 13)
#define B02 midi(9, 13)
#define B03 midi(7, 13)
#define B04 midi(6, 13)
#define B05 midi(10, 13)
#define B06 midi(25, 13)
#define B07 midi(26, 13)
#define B08 midi(27, 13)

#define butt(vb, v1, v0) ((vb) > .001 ? (v1) : (v0))

float preset(float v0, float v1, float v2, float v3, float v4) {
    if (!PRESETS)
        return v0;
    float v = v0;
    v = butt(B01, butt(B05, butt(v0, v0, v1), v1), v);
    v = butt(B02, butt(B05, butt(v0, v0, v2), v2), v);
    v = butt(B03, butt(B05, butt(v0, v0, v3), v3), v);
    v = butt(B04, butt(B05, butt(v0, v0, v4), v4), v);
    return v;
}

#define F1  preset(midi(29, 11), 0.00, 0.00, 0.00, 0.00)
#define P1  preset(midi(13, 12), 0.00, 0.00, 0.00, 0.00)
#define B11 preset(midi(29, 12), 0.00, 0.00, 0.00, 0.00)
#define B12 preset(midi(13, 13), 0.00, 0.00, 0.00, 0.00)
#define B13 preset(midi(29, 13), 0.00, 0.00, 0.00, 0.00)

#define F2  preset(midi(30, 11), 0.00, 0.00, 0.00, 0.00)
#define P2  preset(midi(14, 12), 0.00, 0.00, 0.00, 0.00)
#define B21 preset(midi(30, 12), 0.00, 0.00, 0.00, 0.00)
#define B22 preset(midi(14, 13), 0.00, 0.00, 0.00, 0.00)
#define B23 preset(midi(30, 13), 0.00, 0.00, 0.00, 0.00)

#define F3  preset(midi(31, 11), 0.00, 0.00, 0.00, 0.00)
#define P3  preset(midi(15, 12), 0.00, 0.00, 0.00, 0.00)
#define B31 preset(midi(31, 12), 0.00, 0.00, 0.00, 0.00)
#define B32 preset(midi(15, 13), 0.00, 0.00, 0.00, 0.00)
#define B33 preset(midi(31, 13), 0.00, 0.00, 0.00, 0.00)

#define F4  preset(midi(00, 12), 0.00, 0.00, 0.00, 0.00)
#define P4  preset(midi(16, 12), 0.00, 0.00, 0.00, 0.00)
#define B41 preset(midi(00, 13), 0.00, 0.00, 0.00, 0.00)
#define B42 preset(midi(16, 13), 0.00, 0.00, 0.00, 0.00)
#define B43 preset(midi(00, 14), 0.00, 0.00, 0.00, 0.00)

#define F5  preset(midi(01, 12), 0.00, 0.00, 0.00, 0.00)
#define P5  preset(midi(17, 12), 0.00, 0.00, 0.00, 0.00)
#define B51 preset(midi(01, 13), 0.00, 0.00, 0.00, 0.00)
#define B52 preset(midi(17, 13), 0.00, 0.00, 0.00, 0.00)
#define B53 preset(midi(01, 14), 0.00, 0.00, 0.00, 0.00)

#define F6  preset(midi(02, 12), 0.00, 0.00, 0.00, 0.00)
#define P6  preset(midi(18, 12), 0.00, 0.00, 0.00, 0.00)
#define B61 preset(midi(02, 13), 0.00, 0.00, 0.00, 0.00)
#define B62 preset(midi(18, 13), 0.00, 0.00, 0.00, 0.00)
#define B63 preset(midi(02, 14), 0.00, 0.00, 0.00, 0.00)

#define F7  preset(midi(03, 12), 0.00, 0.00, 0.00, 0.00)
#define P7  preset(midi(19, 12), 0.00, 0.00, 0.00, 0.00)
#define B71 preset(midi(03, 13), 0.00, 0.00, 0.00, 0.00)
#define B72 preset(midi(19, 13), 0.00, 0.00, 0.00, 0.00)
#define B73 preset(midi(03, 14), 0.00, 0.00, 0.00, 0.00)

#define F8  preset(midi(04, 12), 0.00, 0.00, 0.00, 0.00)
#define P8  preset(midi(20, 12), 0.00, 0.00, 0.00, 0.00) 
#define B81 preset(midi(04, 13), 0.00, 0.00, 0.00, 0.00)
#define B82 preset(midi(20, 13), 0.00, 0.00, 0.00, 0.00)
#define B83 preset(midi(04, 14), 0.00, 0.00, 0.00, 0.00)

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

vec3 col2(float x1, float x2, float x){
    return col(x1 + chainsaw(x) * (x2 - x1));
}

// SHAPES

float rect(vec2 uv, vec2 c, vec2 size) {
    uv -= c;
    return smoothstep(size.x + E, size.x - E, abs(uv.x)) * smoothstep(size.y + E, size.y - E, abs(uv.y));
}

float circ(vec2 uv, vec2 c, float size) {
    return smoothstep(abs(size), length(uv - c), E);
}

// DEBUG

#define LT .002
#define GRADS .5

float layout_fader(vec2 uv, float v) {
    float d = clamp(rect(uv, vec2(0, .1 * (v - 1)), vec2(.02, .1 * v)) + rect(uv, vec2(0), vec2(.02, .1)) - rect(uv, vec2(0), vec2(.02 - LT, .1 - LT)), 0, 1);
    d += GRADS * rect(uv, vec2(-.015, -.08), vec2(.005, LT * .5));
    d += GRADS * rect(uv, vec2(-.0175, -.06), vec2(.0025, LT * .5));
    d += GRADS * rect(uv, vec2(-.015, -.04), vec2(.005, LT * .5));
    d += GRADS * rect(uv, vec2(-.0175, -.02), vec2(.0025, LT * .5));
    d += GRADS * rect(uv, vec2(-.015, .00), vec2(.005, LT * .5));
    d += GRADS * rect(uv, vec2(-.0175, .02), vec2(.0025, LT * .5));
    d += GRADS * rect(uv, vec2(-.015, .04), vec2(.005, LT * .5));
    d += GRADS * rect(uv, vec2(-.0175, .06), vec2(.0025, LT * .5));
    d += GRADS * rect(uv, vec2(-.015, .08), vec2(.005, LT * .5));
    return d;
}

float layout_button(vec2 uv, float v) {
    return clamp(rect(uv, vec2(0), vec2(.02)) - rect(uv, vec2(0), vec2(.02 - LT) * (1 - v)), 0, 1);
}

float layout_pot(vec2 uv, float v) {
    float d = clamp(rect(uv, vec2(.055 * (v - 1), 0), vec2(.055 * v, .02)) + rect(uv, vec2(0), vec2(.055, .02)) - rect(uv, vec2(0), vec2(.055 - LT, .02 - LT)), 0, 1);
    d += GRADS * rect(uv, vec2(-.0441, .015), vec2(LT * .5, .005));
    d += GRADS * rect(uv, vec2(-.033, .0175), vec2(LT * .5, .0025));
    d += GRADS * rect(uv, vec2(-.022, .015), vec2(LT * .5, .005));
    d += GRADS * rect(uv, vec2(-.011, .0175), vec2(LT * .5, .0025));
    d += GRADS * rect(uv, vec2(.00, .015), vec2(LT * .5, .005));
    d += GRADS * rect(uv, vec2(.011, .0175), vec2(LT * .5, .0025));
    d += GRADS * rect(uv, vec2(.022, .015), vec2(LT * .5, .005));
    d += GRADS * rect(uv, vec2(.033, .0175), vec2(LT * .5, .0025));
    d += GRADS * rect(uv, vec2(.0441, .015), vec2(LT * .5, .005));
    return d;
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
    uv.y += .04;
    uv.x += .49;d += layout_block(uv, F1, P1, B11, B12, B13);
    uv.x -= .15;d += layout_block(uv, F2, P2, B21, B22, B23);
    uv.x -= .15;d += layout_block(uv, F3, P3, B31, B32, B33);
    uv.x -= .15;d += layout_block(uv, F4, P4, B41, B42, B43);
    uv.x -= .15;d += layout_block(uv, F5, P5, B51, B52, B53);
    uv.x -= .15;d += layout_block(uv, F6, P6, B61, B62, B63);
    uv.x -= .15;d += layout_block(uv, F7, P7, B71, B72, B73);
    uv.x -= .15;d += layout_block(uv, F8, P8, B81, B82, B83);
    return d;
}

// LAYERS

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

vec2 pan(vec2 uv, float zoom, float m) {
    return cmod2(uv * zoom, m + E);
}

vec2 to_polar(vec2 uv) {
    return vec2(
        length(uv),
        atan(uv.y, uv.x)
    );
}

vec2 to_ortho(vec2 uv) {
    return vec2(
        uv.x * cos(uv.y),
        uv.x * sin(uv.y)
    );
}

vec2 kal(vec2 uv, int n, float dist) {
    vec2 uvp = to_polar(uv);
    uvp.y += uvp.x * dist;
    uvp.y = abs(mod(uvp.y + PI / (2 * n), PI / n) - PI / (2 * n));
    return to_ortho(uvp);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv0 = (fragCoord.xy) / iResolution.xy;
    vec2 uv1 = (uv0 - .5) * vec2(iResolution.x / iResolution.y, 1);
    vec2 uv = uv1;
    // B61 / P6 - zoom / F6 - shape
    uv = butt(B61, pan(uv, P6 * 2, F6), uv);
    // B42 - mirror
    // B41 / P4 - bend power / F4 - bend balance
    // B51 / F5 - shift power / P5 - shift speed
    uv = butt(B42, abs(uv), uv);
    uv = butt(B41, uv * 
        cos(uv.x * (P4 + (F4 - .5) + butt(B51, sin(iTime * P5), 0) * F5) * 10) +
        sin(uv.y * (P4 - (F4 - .5) + butt(B51, sin(iTime * P5), 0) * F5) * 10), uv);
    // B71 - kal / P7 - distort speed / F7 - distort
    uv = butt(B71, kal(uv, 3, cos(iTime * P7 * 2)  * F7), uv);
    // F3 - size / P3 squeeze
    float d =  sin(uv.x * 60 * P3) * .05 - .05 + sin(iTime) * .03;
    float t = smoothstep(uv.y + d - E, uv.y + d + E, F3 * .05) * smoothstep(-uv.y - d - E, -uv.y - d + E, F3 * .05);
    // P1 - base color / F1 - Color spread
    // B21 - P2 - Color Speed - F2 spread
    float cd = butt(B21, mod(P2 * iTime * .5, F2), 0);
    vec3 c = t * col2(P1 + cd, P1 + F1 + cd, uv.x);
    // B82 - logo / B83 - invert logo
    c = mix(c, butt(B83, 1 - c, vec3(1)), vec3(B82) * (1 - texture(video1, uv1 + .5).xyz));
//    c = mix(c, butt(B83, 1 - c, vec3(1)), vec3(B82) * texture(image1, uv1 + .5).xyz);

    // P8 / F8 - feedback
    // B81 - invert feedback zoom
    c = mix(c, texture(frame1, (uv0 - .5) * butt(B81, 1 + F8 * spectrum1.x, 1 - F8 * spectrum1.x) + .5).xyz, P8);
    // B00 - debug midi
    c = butt(B00, mix(c, mod(c + .5, 1), show_layout(uv1)), c);
    fragColor = vec4(c,1.0);
}
