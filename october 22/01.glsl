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

void mainImage(out vec4, in vec2);
void main(void) { mainImage(fragColor,gl_FragCoord.xy); }

vec2 lens(vec2 uv, float limit, float power) {
    return uv * (limit - length(uv * power));
}

float a(vec2 uv, float x)
{
    return abs(sin(uv.x * x)) * abs(sin(uv.y * x));
}

#define ZOOM 8
#define SPEED .05

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv0 = (fragCoord.xy) / iResolution.xy;
    vec2 uv = (uv0 - .5) * vec2(iResolution.x / iResolution.y, 1);
    
    uv = lens(uv, 1, .3);
    
    vec3 c = vec3(a(uv + iTime * SPEED, ZOOM) * a(uv + iTime * SPEED * 2, ZOOM * 2) * a(uv + iTime * SPEED * 3, ZOOM * 3));
    
    c *= 4 * vec3(1 - length(uv) * .4, length(uv) * .5, .2);
    
    fragColor = vec4(c, 1.0);
}
