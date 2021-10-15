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
#define E.002

float n(float c){
    return min(1.,max(.0,c));
}

float estep(float threshold,float x,float e){
    return smoothstep(threshold+e,threshold-e,x);
}

float h(vec2 uv,float y0,float height,float e){
    return estep(y0-height*.5,uv.y,-e)*estep(y0+height*.5,uv.y,e);
}

float v(vec2 uv,float x0,float width,float e){
    return estep(x0-width*.5,uv.x,-e)*estep(x0+width*.5,uv.x,e);
}

vec3 n3(vec3 c){
    return min(vec3(1),max(vec3(0),c));
}

vec3 mask(vec3 c0,vec3 c1,float m){
    return n3(c0*(1.-m)+c1*m);
}

float rand(float seed){
    if(seed<0)
    seed*=-1.;
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

#define BG_PLANK_W.6
#define BG_PLANK_H.15
#define PLANK_LIGHT vec3(.48,.36,.23)
#define PLANK_DARK vec3(.28,.20,.14)

#define CORK vec3(.66,.44,.23)

float plank_text(vec2 uv,vec2 size,float plank_seed,float range){
    if(rand(plank_seed++)>.5)
    uv.x=(size.x-uv.x);
    return h(
        uv+vec2(.0,sin(uv.x*(15.+15*rand(plank_seed++)))*.002),
        size.y*(.05+.9*rand(plank_seed++)),
        cos(uv.x*(10.+range*(rand(plank_seed++)-.5)))*.01
    ,E);
}

float plank_dark(vec2 uv,vec2 size,float plank_seed){
    float m=.0;
    
    m+=plank_text(uv,size,plank_seed++,3.);
    m+=plank_text(uv,size,plank_seed++,3.);
    
    m+=v(uv,-.005,.02,E);
    m+=h(uv,-.005,.02,E);
    m+=v(uv,size.x+.005,.02,E);
    m+=h(uv,size.y+.005,.02,E);
    
    return n(m);
}

vec3 plank(vec3 c,vec2 uv,vec2 center,vec2 size,float plank_seed,float color_shift){
    uv+=size*.5-center;
    
    vec3 c0=PLANK_LIGHT-rand(plank_seed++)*.02+color_shift;
    vec3 c1=PLANK_DARK;
    
    float pmask=rect(uv,size*.5,size,.0,.0,E);
    float pmask2=rect(uv,size*.5,size-.005,.0,.0,E);
    
    c=mask(c,c0,pmask2);
    
    for(int i=0;i<50;i++)
    c=mask(c,c1,pmask2*rand(plank_seed++)*.2*plank_text(uv,size,plank_seed++,20.));
    
    plank_seed++;
    
    c=mask(c,c0*1.3,pmask2*.5*plank_dark(uv+vec2(.005),size,plank_seed));
    c=mask(c,c0*1.3,pmask2*.5*plank_dark(uv+vec2(-.005),size,plank_seed));
    c=mask(c,c1,pmask*plank_dark(uv,size,plank_seed));
    
    return c;
}

vec3 background(vec2 uv0){
    vec2 size=vec2(BG_PLANK_W,BG_PLANK_H);
    
    uv0.x+=mod(uv0.y,2.*size.y)<size.y?size.x*.5:.0;
    vec2 uv=vec2(mod(uv0.x,size.x),mod(uv0.y,size.y));
    
    float plank_seed=floor(uv0.x/size.x)*938+floor(uv0.y/size.y)*324.+100;
    
    return plank(PLANK_DARK,uv,size*.5,size,plank_seed,.0);
}

float writing(vec2 uv,vec2 center,vec2 size,float ampl,float angle,float seed,float e){
    uv-=center;
    uv=rot(uv,angle);
    return h(
        vec2(uv.x,uv.y+sin((uv.x+rand(seed++))*123.)*sin((uv.x+rand(seed++))*256.)*sin((uv.x+rand(seed++))*89.)*sin((uv.x+rand(seed++))*111.)*ampl),
    .0,size.y*.25,E)*rect(uv,vec2((rand(seed++)-.5)*size.x*.1,(rand(seed++)-.5)*size.y*.5),vec2(size.x*.9-rand(seed++)*size.x*.6,size.y),.0,.0,e);
}

vec3 shelf(vec3 c,vec2 uv,float seed){
    float shadow=n(
        rect(uv,vec2(.03,-.18),vec2(.35,.1),.0,.0,E)+
        tri(uv,vec2(.175,-.115),vec2(.06,.03),.0,.0,E)+
        tri(uv,vec2(-.16,-.20),vec2(.06,.03),.0,.75,E)
    );
    
    c=mask(c,vec3(.0),.3*shadow);
    
    float label_x=(rand(seed++)-.5)*.2;
    
    float shadow2=n(
        rect(uv+vec2(-.02,.02),vec2(label_x,-.08),vec2(.10,.05),.0,.0,E)+
        tri(uv+vec2(-.02,.02),vec2(label_x+.05,-.08),vec2(.02,.045),.0,.0,E)
    );
    
    c=mask(c,vec3(.0),.3*shadow2);
    
    c=mask(c,vec3(.9,.9,.85),n(
        rect(uv,vec2(label_x,-.08),vec2(.10,.05),.0,.0,E)+
        tri(uv,vec2(label_x-.05,-.08),vec2(.02,.045),.0,.0,E)
    ));
    c=mask(c,vec3(.9,.9,.85)*.9,tri(uv,vec2(label_x+.05,-.08),vec2(.02,.045),.0,.0,E));
    
    float price=1.+floor(rand(seed++)*4.);
    
    float x;
    
    for(float i=0.;i<price;i++){
        x=label_x-.015-(i-price*.5)*.021+(uv.y+.08)*.10;
        c=mask(c,vec3(.2),v(uv,x+sin(uv.y*600.)*.008,.005,E)*rect(uv,vec2(label_x,-.08),vec2(.10,.02),.0,.0,E));
        c=mask(c,vec3(.2),v(uv,x,.003,E)*rect(uv,vec2(label_x,-.08),vec2(.10,.025),.0,.0,E));
    }
    
    c=plank(c,uv,vec2(.0,-.15),vec2(.35,.1),seed,-.04);
    
    return c;
}

vec3 potion(vec3 c,vec2 uv,float seed){
    
    float bg,outside,shadow,liquid_mask;
    
    float form=rand(seed++);
    
    vec2 label_pos=vec2((rand(seed++)-.5)*.02,-.01+(rand(seed++)-.5)*.02);
    
    if(form<.333){
        bg=ell(uv,vec2(.0,-.01),vec2(.2,.18),.0,.0,E);
        outside=n(
            ellh(uv,vec2(.0,-.01),vec2(.2,.18),.03,.0,E)+
            ellh(uv,vec2(.01,-.03),vec2(.2,.18),.03,.0,E)*
            rect(uv,vec2(-.05,.04),vec2(.03,.08),.0,.0,E*5.)*.7
        );
        
        shadow=ell(uv+vec2(-.03,.03),vec2(.0,-.01),vec2(.2,.18),.0,.0,E);
        
        liquid_mask=ell(uv,vec2(.0,-.01),vec2(.2,.18),.0,.0,E);
    }else if(form<.66){
        bg=rect(uv,vec2(.0,-.01),vec2(.15,.18),.0,.0,E);
        outside=n(
            recth(uv,vec2(.0,-.01),vec2(.15,.18),.03,.0,E)+
            recth(uv,vec2(.02,-.03),vec2(.15,.18),.03,.0,E)*
            rect(uv,vec2(-.05,.04),vec2(.03,.08),.0,.0,E*5.)*.7
        );
        
        shadow=rect(uv+vec2(-.03,.03),vec2(.0,-.01),vec2(.15,.18),.0,.0,E);
        
        liquid_mask=rect(uv,vec2(.0,-.01),vec2(.15,.18),.0,.0,E);
    }else{
        bg=n(
            tri(uv,vec2(.0,.01),vec2(.23,.23),.0,.0,E)-
            rect(uv,vec2(.0,.15),vec2(.1,.1),.0,.0,E)
        );
        outside=n(
            trih(uv,vec2(.0,.01),vec2(.23,.23),.04,.0,E)+
            trih(uv,vec2(.01,-.02),vec2(.23,.23),.03,.0,E)*
            rect(uv,vec2(-.03,.0),vec2(.03,.08),.0,.0,E*5.)*.7
        );
        
        shadow=tri(uv+vec2(-.03,.03),vec2(.0,.01),vec2(.23,.23),.0,.0,E);
        
        liquid_mask=tri(uv,vec2(.0,.01),vec2(.23,.23),.0,.0,E);
        
        label_pos+=vec2(.0,-.03);
    }
    
    bg=n(bg+rect(uv,vec2(.0,.10),vec2(.06,.07),.03,.0,E));
    
    outside=n(
        outside+
        recth(uv,vec2(.0,.10),vec2(.06,.07),.03,.0,E)-
        rect(uv,vec2(.0,.10),vec2(.03,.08),.0,.0,E)*2.
    );
    
    float cork=n(
        tri(uv,vec2(.0,.105),vec2(.05,.1),.0,.5,E)-
        rect(uv,vec2(.0,.08),vec2(.033,.06),.0,.0,E)
    );
    
    shadow=n(
        shadow+
        rect(uv+vec2(-.03,.03),vec2(.0,.10),vec2(.06,.07),.03,.0,E)+
        tri(uv+vec2(-.03,.03),vec2(.0,.105),vec2(.05,.1),.0,.5,E)
    );
    
    float liquid_h=.1+rand(seed++)*.2;
    
    float liquid=n(
        liquid_mask*h(uv,-.1+liquid_h*.5*.5,liquid_h*.5,E)
        -outside
    );
    
    c=mask(c,vec3(.0),.3*shadow);
    
    c=mask(c,mask(col(rand(seed++)),col(rand(seed+++20.)),(uv.y+.18-liquid_h*.5)*13.),liquid);
    c=mask(c,CORK+.05*rand(seed++),cork);
    c=mask(c,vec3(1.),.3*bg);
    c=mask(c,vec3(1.),.7*outside);
    
    float label_angle=(rand(seed++)-.5)*.05;
    float label_width=.07+rand(seed++)*.04;
    
    c=mask(c,vec3(.9,.9,.8+rand(seed++)*.1),rect(uv,label_pos,vec2(label_width,.04),.0,label_angle,E));
    
    c=mask(c,vec3(.2+(rand(seed++)-.5)*.1),writing(uv,label_pos,vec2(label_width,.04),.01,label_angle,seed++,E));
    
    c=shelf(c,uv,seed++);
    
    return c;
}

vec3 image(vec2 uv0,float t){
    vec3 c=vec3(.0);
    
    vec2 uv=uv0-vec2(t*.1);
    
    c=background(uv);
    
    float seed=floor(uv.x*2.)*493.+floor(uv.y*2.)*482.;
    
    c=potion(c,mod(uv,.5)-.25,seed);
    
    return c;
}

vec3 colorShiftImage(vec2 uv,float t0,float t1,float size){
    if(size<.00001)
    return image(uv,t0);
    
    vec3 c1=image(uv+vec2(size*sin(t1),size*cos(t1)),t0);
    vec3 c2=image(uv+vec2(size*sin(t1+2.),size*cos(t1+2.)),t0);
    vec3 c3=image(uv+vec2(size*sin(t1+4.),size*cos(t1+4.)),t0);
    return vec3(c1.x,c2.y,c3.z);
}

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
    vec2 uv=(fragCoord.xy/iResolution.xy-.5);
    uv.x*=iResolution.x/iResolution.y;
    
    vec3 c=colorShiftImage(uv,iTime,iTime*5.,.0);
    
    fragColor=vec4(c,1.);
}