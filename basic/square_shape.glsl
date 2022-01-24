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

float square(vec2 uv, vec2 c, float size) {
    uv -= c;
    return smoothstep(size + E, size - E, abs(uv.x + uv.y) + abs(uv.x - uv.y));
}

#define SIZE .25
#define SPEED 1

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv0 = (fragCoord.xy) / iResolution.xy;
    vec2 uv = (uv0 - .5) * vec2(iResolution.x / iResolution.y, 1);
    
    vec3 c = vec3(1) * square(uv, vec2(sin(iTime * SPEED * PI), cos(iTime * SPEED * PI)) * .1, SIZE);
    
    fragColor = vec4(c, 1);
}
