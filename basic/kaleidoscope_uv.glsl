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

vec2 kal(vec2 uv, int n) {
    vec2 uvp = to_polar(uv);
    uvp.y = abs(mod(uvp.y + PI / (2 * n), PI / n) - PI / (2 * n));
    return to_ortho(uvp);
}

#define ZOOM 3
#define SPEED .5

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv0 = (fragCoord.xy) / iResolution.xy;
    vec2 uv = (uv0 - .5) * vec2(iResolution.x / iResolution.y, 1);
    
    uv = kal(uv, 3);
    
    uv = mod(uv * ZOOM - iTime * SPEED, 1);
    
    vec3 c = vec3(uv, 0);
    
    fragColor = vec4(c, 1);
}
