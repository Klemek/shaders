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

float rand(float seed){
    float v=pow(seed,6./7.);
    v*=sin(v)+1.;
    return v-floor(v);
}

vec3 col(float x){
    return vec3(
        .5*(sin(x*2.*PI)+1.),
        .5*(sin(x*2.*PI+2.*PI/3.)+1.),
        .5*(sin(x*2.*PI-2.*PI/3.)+1.)
    );
}

vec2 rot(vec2 uv,float angle){
    return vec2(
        cos(angle*2.*PI)*uv.x-sin(angle*2.*PI)*uv.y,
        sin(angle*2.*PI)*uv.x+cos(angle*2.*PI)*uv.y
    );
}

float h(vec2 uv,float y0,float height,float e){
    return estep(y0-height*.5,uv.y,-e)*estep(y0+height*.5,uv.y,e);
}

float v(vec2 uv,float x0,float width,float e){
    return estep(x0-width*.5,uv.x,-e)*estep(x0+width*.5,uv.x,e);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

float circle(vec2 uv,vec2 center,vec2 size,float r,float angle,float e){
    uv-=center;
    return estep(min(size.x,size.y)*.5,length(uv),e*2.);
}

float rect(vec2 uv,vec2 center,vec2 size,float r,float angle,float e){
    uv-=center;
    uv=rot(uv,angle);
    return
    estep(size.x*.5,uv.x,e)*
    estep(-size.x*.5,uv.x,-e)*
    estep(size.y*.5,uv.y,e)*
    estep(-size.y*.5,uv.y,-e);
}

float tri(vec2 uv,vec2 center,vec2 size,float r,float angle,float e){
    uv-=center;
    uv=rot(uv,angle);
    uv+=vec2(0,size.y*.5);
    return
    estep(-size.x*.5,uv.x-uv.y*size.x*.5/size.y,-e*2.)*
    estep(-size.x*.5,-uv.x-uv.y*size.x*.5/size.y,-e*2.)*
    estep(.0,uv.y,-e);
}

float ell(vec2 uv,vec2 center,vec2 size,float r,float angle,float e){
    uv-=center;
    uv=rot(uv,angle);
    float t;
    float c;
    vec2 p;
    if(size.x>=size.y){
        t=size.x;
        c=pow(pow(size.x*.5,2.)-pow(size.y*.5,2.),.5);
        p=vec2(c,.0);
    }else{
        t=size.y;
        c=pow(pow(size.y*.5,2.)-pow(size.x*.5,2.),.5);
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
    uv=rot(uv,angle);
    return n(
        rect(uv,vec2(.0),size,.0,.0,e)-
        rect(uv,vec2(.0),size-vec2(r),.0,.0,e)
    );
}

// WIP
float trih(vec2 uv,vec2 center,vec2 size,float r,float angle,float e){
    uv-=center;
    uv=rot(uv,angle);
    return n(
        tri(uv,vec2(.0),size,.0,.0,e)-
        tri(uv,vec2(.0,-r*.2),size-vec2(r*pow(2,.5)),.0,.0,e)
    );
}

float ellh(vec2 uv,vec2 center,vec2 size,float r,float angle,float e){
    uv-=center;
    uv=rot(uv,angle);
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
    uv=rot(uv,angle);
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
    uv=rot(uv,angle);
    return n(
        rectr(uv,vec2(.0),size,r,.0,E)+
        rect(uv,vec2(.0,-size.y*.5+r*.5),vec2(size.x,r),.0,.0,E)
    );
}

float trir(vec2 uv,vec2 center,vec2 size,float r,float angle,float e){
    uv-=center;
    uv=rot(uv,angle);
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
    uv=rot(uv,angle);
    return n(
        rectr(uv,vec2(.0),size,r,.0,e)-
        rectr(uv,vec2(.0),size-vec2(r),r,.0,e)
    );
}

// WIP
float trirh(vec2 uv,vec2 center,vec2 size,float r,float angle,float e){
    uv-=center;
    uv=rot(uv,angle);
    return n(
        trir(uv,vec2(.0),size,r,.0,e)-
        trir(uv,vec2(.0,-r*.2),size-vec2(r),r,.0,e)
    );
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#define SHADOW vec2(-.03,.03)
#define SHADOW_V.3

float bubble_bg(vec2 uv){
    return n(
        line(uv,vec2(-.12,.0),vec2(.12,.0),.3,E)+
        circle(uv,vec2(-.22,-.1),vec2(.13),.0,.0,E)+
        circle(uv,vec2(-.32,-.18),vec2(.07),.0,.0,E)
    );
}

#define DOT_TIME.3

#define BG vec3(.8)
#define DOT_DARK vec3(.4)
#define DOT_LIGHT vec3(.6)

vec3 bubble(vec3 c,vec2 uv,float t0,bool last_dot){
    c=mask(c,vec3(.0),SHADOW_V*bubble_bg(uv+SHADOW));
    c=mask(c,BG,bubble_bg(uv));
    
    float t1=mod(t0,DOT_TIME*3.);
    
    c=mask(c,t1<DOT_TIME?DOT_DARK:DOT_LIGHT,circle(uv,vec2(-.12,.0),vec2(.1),.0,.0,E));
    c=mask(c,t1>DOT_TIME&&t1<DOT_TIME*2.?DOT_DARK:DOT_LIGHT,circle(uv,vec2(.0),vec2(.1),.0,.0,E));
    if(last_dot)
    c=mask(c,t1>DOT_TIME*2.?DOT_DARK:DOT_LIGHT,circle(uv,vec2(.12,.0),vec2(.1),.0,.0,E));
    
    return c;
}

float letter_open_mask(vec2 uv,float he){
    return n(trir(uv,vec2(.0,.14+.1*he),vec2(.53,max(.05,.2*he)),.05,.0,E)*h(uv,.29,.2,E));
}

#define LETTER_TIME 1.

vec3 letter(vec3 c,vec2 uv,float t0){
    float letter_bg=rectr(uv,vec2(.0),vec2(.54,.4),.1,.0,E);
    float letter_inside=letter_bg*trir(uv,vec2(.0,.1),vec2(.53,.2),.05,.5,E);
    float letter_closed=.0;
    float letter_open=.0;
    float letter_shadow=rectr(uv+SHADOW,vec2(.0),vec2(.54,.4),.1,.0,E);
    
    float he;
    
    if(t0<LETTER_TIME*.5){
        he=min(1.,4.*(LETTER_TIME*.5-t0));
        letter_closed=rectr(uv,vec2(.0),vec2(.54,.4),.1,.0,E)*trir(uv,vec2(.0,.23-.1*he),vec2(.53,max(.05,.2*he)),.05,.5,E);
    }else{
        he=min(1.,4.*(t0-LETTER_TIME*.5));
        letter_open=letter_open_mask(uv,he);
        letter_shadow=n(letter_shadow+letter_open_mask(uv+SHADOW,he));
    }
    
    c=mask(c,vec3(.0),SHADOW_V*letter_shadow);
    c=mask(c,vec3(.9),letter_bg);
    c=mask(c,vec3(.7),letter_inside);
    c=mask(c,vec3(.9),letter_closed);
    c=mask(c,vec3(.7),letter_open);
    
    return c;
}

vec3 letter_front(vec3 c,vec2 uv,float t0){
    float letter_bg=rectr(uv,vec2(.0),vec2(.54,.4),.1,.0,E);
    float letter_inside=letter_bg*trir(uv,vec2(.0,.1),vec2(.53,.2),.05,.5,E);
    
    return mask(c,vec3(.9),n(letter_bg-letter_inside));
}

#define DOT_AFTER vec3(.9,.8,.1)

vec3 free_dot(vec3 c,vec2 uv,float t0){
    
    uv-=vec2(.12,.0)*(2.-t0)*.5;
    
    for(float v=.0;v<1.;v+=.11)
    c=mask(c,vec3(1.),line(uv,vec2(.0),rot(vec2(n(t0-.5)*.06),v),.05,E));
    
    c=mask(c,mask(DOT_DARK,DOT_AFTER,n(t0*2.)),circle(uv,vec2(.0),vec2(.1),.0,.0,E));
    
    return c;
}

vec3 stamp(vec3 c,vec2 uv,float t0){
    
    uv*=min(1.,t0*.9);
    
    float heart=n(
        circle(uv,vec2(.02,.03),vec2(.07),.0,.0,E)+
        circle(uv,vec2(-.02,.03),vec2(.07),.0,.0,E)+
        trir(uv,vec2(0,-.01),vec2(.09,.06),.02,.5,E)
    );
    
    c=mask(c,vec3(.9,.0,.0),n(t0)*heart);
    
    return c;
}

vec3 image(vec2 uv,float t0){
    vec3 c=vec3(.1,.6,.3);
    
    float t1=mod(t0,8.);
    
    c=bubble(c,uv+vec2(t1<2.?.0:(t1<4.?t1-2.:t1-8.),.0),t1+.5,t1<2.||t1>6.);
    
    float letter_x=t1<4.?t1-4.:(t1<6.?.0:t1-6.);
    
    c=letter(c,uv+vec2(letter_x,.0),4.5-t1);
    
    if(t1>2.&&t1<4.1)
    c=free_dot(c,uv-vec2(.0,sin((t1-2.)*.5*PI)*.6),(t1-2.));
    
    c=letter_front(c,uv+vec2(letter_x,.0),4.5-t1);
    
    c=stamp(c,uv+vec2(letter_x,.0),t1-4.5);
    
    return c;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=(fragCoord.xy/iResolution.xy-.5);
    uv.x*=iResolution.x/iResolution.y;
    
    vec3 c=image(uv,iTime*.8);
    
    fragColor=vec4(c,1.);
}