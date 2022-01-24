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

vec2 lens(vec2 uv, float limit, float power) {
    return uv * (limit - length(uv * power));
}

#define ZOOM 1
#define LIMIT -1
#define POWER -10
#define SPEED .5

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv0 = (fragCoord.xy) / iResolution.xy;
    vec2 uv = (uv0 - .5) * vec2(iResolution.x / iResolution.y, 1);
    
    uv = lens(uv, LIMIT + sin(iTime * SPEED * PI) * 5, POWER + cos(iTime * SPEED * PI) * 5);
    
    uv = mod(uv * ZOOM, 1);
    
    vec3 c = vec3(uv, 0);
    
    fragColor = vec4(c, 1);
}
