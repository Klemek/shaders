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

vec2 spiral2(vec2 uv, float k1, float k2, float delta) {
    float r = length(uv);
    float t = mod(atan(uv.y, uv.x) + delta, 2 * PI);
    vec2 tmp = (t - vec2(0, log(r) / k1)) / (PI * vec2(k2, 2));
    return vec2(tmp.x + int(tmp.y), mod(tmp.y, 1));
}

#define K1 .1
#define K2 .25
#define SPEED .5

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv0 = (fragCoord.xy) / iResolution.xy;
    vec2 uv = (uv0 - .5) * vec2(iResolution.x / iResolution.y, 1);
    
    uv = spiral2(uv, K1, K2, iTime * SPEED * PI);
    
    vec3 c = vec3(mod(uv, 1), mod(uv.x / 5, 1));
    
    fragColor = vec4(c, 1);
}
