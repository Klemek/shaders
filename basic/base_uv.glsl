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

#define ZOOM 5

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv0 = (fragCoord.xy) / iResolution.xy;
    vec2 uv = (uv0 - .5) * vec2(iResolution.x / iResolution.y, 1);
    
    uv = mod(uv * ZOOM, 1);
    
    vec3 c = vec3(uv, 0);
    
    fragColor = vec4(c, 1);
}
