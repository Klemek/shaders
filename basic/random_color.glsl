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

float rand(float seed){
    float v=pow(abs(seed),6./7.);
    v*=sin(v)+1.;
    return fract(v);
}

vec3 col(float x){
    return vec3(
        .5*(sin(x*2.*PI)+1.),
        .5*(sin(x*2.*PI+2.*PI/3.)+1.),
        .5*(sin(x*2.*PI-2.*PI/3.)+1.)
    );
}

#define ZOOM 20
#define SPEED .5

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv0 = (fragCoord.xy) / iResolution.xy;
    vec2 uv = (uv0 - .5) * vec2(iResolution.x / iResolution.y, 1);
    
    uv += .5;
    
    vec3 c = vec3(col(rand(int(uv.x * ZOOM) + int(uv.y * ZOOM) * ZOOM) + iTime * SPEED));
    
    fragColor = vec4(c, 1);
}
