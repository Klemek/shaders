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

void mainImage(out vec4,in vec2);
void main(void){mainImage(fragColor,gl_FragCoord.xy);}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#define PI 3.1415927
#define E.001
#define SQRT2 1.4142136

float n(float c){
    return min(1.,max(.0,c));
}

float estep(float threshold,float x,float e){
    return smoothstep(threshold+e,threshold-e,x);
}

vec3 n3(vec3 c){
    return min(vec3(1),max(vec3(0),c));
}

vec3 mask(vec3 c0,vec3 c1,float m){
    return n3(c0*(1.-m)+c1*m);
}

float h(vec2 uv,float y0,float height,float e){
    return estep(y0-height*.5,uv.y,-e)*estep(y0+height*.5,uv.y,e);
}

float v(vec2 uv,float x0,float width,float e){
    return estep(x0-width*.5,uv.x,-e)*estep(x0+width*.5,uv.x,e);
}

float rand(float seed){
    float v=pow(seed,6./7.);
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

mat2 rot(float angle){
    return mat2(
        cos(angle*2.*PI),-sin(angle*2.*PI),
        sin(angle*2.*PI),cos(angle*2.*PI)
    );
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

float circle(vec2 uv,vec2 center,vec2 size,float r,float angle,float e){
    uv-=center;
    return estep(min(size.x,size.y)*.5,length(uv),e*2.);
}

float rect(vec2 uv,vec2 center,vec2 size,float r,float angle,float e){
    uv-=center;
    uv*=rot(angle);
    return
    estep(size.x*.5,uv.x,e)*
    estep(-size.x*.5,uv.x,-e)*
    estep(size.y*.5,uv.y,e)*
    estep(-size.y*.5,uv.y,-e);
}

float tri(vec2 uv,vec2 center,vec2 size,float r,float angle,float e){
    uv-=center;
    uv*=rot(angle);
    uv+=vec2(0,size.y*.5);
    return
    estep(-size.x*.5,uv.x-uv.y*size.x*.5/size.y,-e*2.)*
    estep(-size.x*.5,-uv.x-uv.y*size.x*.5/size.y,-e*2.)*
    estep(.0,uv.y,-e);
}

float ell(vec2 uv,vec2 center,vec2 size,float r,float angle,float e){
    uv-=center;
    uv*=rot(angle);
    float t;
    float c;
    vec2 p;
    if(size.x>=size.y){
        t=size.x;
        c=sqrt((size.x*.5)*(size.x*.5)-(size.y*.5)*(size.y*.5));
        p=vec2(c,.0);
    }else{
        t=size.y;
        c=sqrt((size.y*.5)*(size.y*.5)-(size.x*.5)*(size.x*.5));
        p=vec2(.0,c);
    }
    return estep(t,length(uv-p)+length(uv+p),e*4.);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

float circleh(vec2 uv,vec2 center,vec2 size,float r,float angle,float e){
    uv-=center;
    return n(
        circle(uv,vec2(.0),size,.0,.0,e)-
        circle(uv,vec2(.0),size-vec2(r),.0,.0,e)
    );
}

float recth(vec2 uv,vec2 center,vec2 size,float r,float angle,float e){
    uv-=center;
    uv*=rot(angle);
    return n(
        rect(uv,vec2(.0),size,.0,.0,e)-
        rect(uv,vec2(.0),size-vec2(r),.0,.0,e)
    );
}

// WIP
float trih(vec2 uv,vec2 center,vec2 size,float r,float angle,float e){
    uv-=center;
    uv*=rot(angle);
    return n(
        tri(uv,vec2(.0),size,.0,.0,e)-
        tri(uv,vec2(.0,-r*.2),size-vec2(r*SQRT2),.0,.0,e)
    );
}

float ellh(vec2 uv,vec2 center,vec2 size,float r,float angle,float e){
    uv-=center;
    uv*=rot(angle);
    return n(
        ell(uv,vec2(.0),size,.0,.0,e)-
        ell(uv,vec2(.0),size-vec2(r),.0,.0,e)
    );
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

float line(vec2 uv,vec2 p1,vec2 p2,float size,float e){
    vec2 diff=p2-p1;
    
    float angle=atan(diff.y,diff.x)/(2.*PI);
    return n(
        circle(uv,p1,vec2(size),.0,.0,e)+
        circle(uv,p2,vec2(size),.0,.0,e)+
        rect(uv,(p1+p2)*.5,vec2(length(diff),size),.0,-angle,e)
    );
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

float rectr(vec2 uv,vec2 center,vec2 size,float r,float angle,float e){
    uv-=center;
    uv*=rot(angle);
    vec2 isize=size-vec2(r);
    vec2 v1=isize*.5;
    vec2 v2=v1*vec2(-1,1);
    return n(
        circle(uv,+v1,vec2(r),.0,.0,e)+
        circle(uv,-v1,vec2(r),.0,.0,e)+
        circle(uv,+v2,vec2(r),.0,.0,e)+
        circle(uv,-v2,vec2(r),.0,.0,e)+
        rect(uv,vec2(.0),vec2(size.x,isize.y),.0,.0,e)+
        rect(uv,vec2(.0),vec2(isize.x,size.y),.0,.0,e)
    );
}

float rectr2(vec2 uv,vec2 center,vec2 size,float r,float angle,float e){
    uv-=center;
    uv*=rot(angle);
    return n(
        rectr(uv,vec2(.0),size,r,.0,E)+
        rect(uv,vec2(.0,-size.y*.5+r*.5),vec2(size.x,r),.0,.0,E)
    );
}

float trir(vec2 uv,vec2 center,vec2 size,float r,float angle,float e){
    uv-=center;
    uv*=rot(angle);
    vec2 isize=size-vec2(r);
    vec2 v1=isize*.5;
    vec2 v2=v1*vec2(-1,1);
    vec2 v3=(v1+v2)*.5;
    return n(
        line(uv,-v1,v3,r,e)+
        line(uv,-v1,-v2,r,e)+
        line(uv,v3,-v2,r,e)+
        tri(uv,vec2(.0),size-vec2(r),.0,.0,e)
    );
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

float rectrh(vec2 uv,vec2 center,vec2 size,float r,float angle,float e){
    uv-=center;
    uv*=rot(angle);
    return n(
        rectr(uv,vec2(.0),size,r,.0,e)-
        rectr(uv,vec2(.0),size-vec2(r),r,.0,e)
    );
}

// WIP
float trirh(vec2 uv,vec2 center,vec2 size,float r,float angle,float e){
    uv-=center;
    uv*=rot(angle);
    return n(
        trir(uv,vec2(.0),size,r,.0,e)-
        trir(uv,vec2(.0,-r*.2),size-vec2(r),r,.0,e)
    );
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#define SKY vec3(.4,.9,1.)
#define CLOUD_COMPLEXITY 20

float cloud_base(vec2 uv,float seed){
    float cloud=.0;
    
    float min_x=.0;
    float max_x=.0;
    
    float posx,posy;
    vec2 pos,size;
    
    for(int i=0;i<CLOUD_COMPLEXITY;i++){
        size=vec2(.1+rand(seed++)*.2,.1+rand(seed++)*.1);
        posx=rand(seed++);
        posy=rand(seed++);
        pos=vec2((posx*posx-.5)*.5,(posy*posy)*.1+size.y*.2);
        
        min_x=min(min_x,pos.x);
        max_x=max(max_x,pos.x);
        
        cloud+=ell(uv,pos,size,.0,(rand(seed++)-.5)*.1,E);
    }
    
    return n(cloud);
}

vec3 cloud(vec3 c,vec2 uv,float t,float y){
    uv+=vec2(t,.0);
    float seed=floor(uv.x+.5);
    uv.x=fract(uv.x+.5)-.5;
    
    uv-=vec2(rand(seed++)*.1,y+(rand(seed++)-.5)*.3);
    
    float base=cloud_base(uv,seed);
    float shadow_in=base-cloud_base(uv-vec2(.01,.05),seed)*base;
    
    c=mask(c,vec3(1.),.9*(base-shadow_in));
    c=mask(c,vec3(.9),.9*shadow_in);
    
    return c;
}

vec3 image(vec2 uv,float t){
    vec3 c=SKY;
    
    c=cloud(c,uv,t*.3,.2);
    c=cloud(c,uv,t*.4,.0);
    c=cloud(c,uv,t*.5,-.2);
    
    return c;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=(fragCoord.xy/iResolution.xy-.5);
    uv.x*=iResolution.x/iResolution.y;
    
    vec3 c=image(uv,iTime);
    
    fragColor=vec4(c,1.);
}