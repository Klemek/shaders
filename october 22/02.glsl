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


#define SIZE .02
#define E .0001

#define PI 3.14159

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

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv0 = (fragCoord.xy) / iResolution.xy;
    vec2 uv = (uv0 - .5) * vec2(iResolution.x / iResolution.y, 1);
    
    uv = kal(uv, 3, cos(iTime * .9));
    
    float d =  sin(uv.x * 15) * .05 - .05 + sin(iTime) * .03;
    
    vec3 c = vec3(smoothstep(uv.y + d - E, uv.y + d + E, SIZE) * smoothstep(-uv.y - d - E, -uv.y - d + E, SIZE));
    
//    c *= vec3(1, uv.x * 2, 1 - uv.x * 2);

    fragColor = vec4(c, 1.0);
}
