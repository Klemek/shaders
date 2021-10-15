#ifdef GL_ES
precision highp float;
#endif

uniform float iTime;
uniform vec2 iResolution;

varying vec3 v_normal;
varying vec2 v_texcoord;

#define PI 3.1415927
#define E.001

float n(float c){
    return min(1.,max(.0,c));
}

float rand(float seed){
    float v=pow(seed,6./7.);
    v*=sin(v)+1.;
    return v-floor(v);
}

vec3 color(float x){
    return vec3(
        .5*(sin(x*2.*PI)+1.),
        .5*(sin(x*2.*PI+2.*PI/3.)+1.),
        .5*(sin(x*2.*PI-2.*PI/3.)+1.)
    );
}

vec3 n3(vec3 c){
    return min(vec3(1),max(vec3(0),c));
}

vec3 mask(vec3 c0,vec3 c1,float m){
    return n3(c0*(1.-m)+c1*m);
}

float circle(vec2 uv,vec2 center,float size,float e){
    uv-=center;
    return smoothstep(size*.5+e,size*.5-e,length(uv));
}

float ellipse(vec2 uv,vec2 center,vec2 size,float e){
    uv-=center;
    uv.y*=size.x/size.y;
    return circle(uv,vec2(.0),size.x,e);
}

vec2 rotate(vec2 uv,float angle){
    return vec2(
        cos(angle*PI)*uv.x-sin(angle*PI)*uv.y,
        sin(angle*PI)*uv.x+cos(angle*PI)*uv.y
    );
}

float rect(vec2 uv,vec2 center,vec2 size,float angle,float e){
    uv-=center;
    uv=rotate(uv,angle);
    return
    smoothstep(size.x*.5+e,size.x*.5-e,uv.x)*
    smoothstep(-size.x*.5-e,-size.x*.5+e,uv.x)*
    smoothstep(size.y*.5+e,size.y*.5-e,uv.y)*
    smoothstep(-size.y*.5-e,-size.y*.5+e,uv.y);
}

float rrect(vec2 uv,vec2 center,vec2 size,float r,float angle,float e){
    uv-=center;
    uv=rotate(uv,angle);
    vec2 isize=size-vec2(r);
    vec2 v1=isize*.5;
    vec2 v2=v1*vec2(-1,1);
    return n(
        circle(uv,+v1,r,e)+
        circle(uv,-v1,r,e)+
        circle(uv,+v2,r,e)+
        circle(uv,-v2,r,e)+
        rect(uv,vec2(.0),vec2(size.x,isize.y),.0,e)+
        rect(uv,vec2(.0),vec2(isize.x,size.y),.0,e)
    );
}

float rrect2(vec2 uv,vec2 center,vec2 size,float r,float angle,float e){
    uv-=center;
    uv=rotate(uv,angle);
    return n(
        rrect(uv,vec2(.0),size,r,.0,E)+
        rect(uv,vec2(.0,-size.y*.5+r*.5),vec2(size.x,r),.0,E)
    );
}

float triangle(vec2 uv,vec2 center,vec2 size,float angle,float e){
    uv-=center;
    uv=rotate(uv,angle);
    uv+=vec2(0,size.y*.5);
    return
    smoothstep(-size.x*.5-e,-size.x*.5+e,uv.x-uv.y*size.x*.5/size.y)*
    smoothstep(-size.x*.5-e,-size.x*.5+e,-uv.x-uv.y*size.x*.5/size.y)*
    smoothstep(-e,+e,uv.y);
}

float line(vec2 uv,vec2 p1,vec2 p2,float size,float e){
    vec2 diff=p2-p1;
    
    float angle=atan(diff.y,diff.x)/PI;
    return n(
        circle(uv,p1,size,e)+
        circle(uv,p2,size,e)+
        rect(uv,(p1+p2)*.5,vec2(length(diff),size),-angle,e)
    );
}

vec3 building(float x,vec2 uv,vec3 c){
    float height=.4+.35*rand(floor(x)+8234.);
    height-=mod(height,.1)-.07;
    
    float color_x=rand(floor(x)+233.);
    vec3 bg_color=vec3(.2)+.05*color(color_x);
    vec3 door_color=vec3(.2,.0,.0)+.1*color(color_x+.5);
    
    c=mask(c,bg_color,rrect2(uv,vec2(.0,-.2+height*.5),vec2(.3,height),.01,.0,E));
    
    float door_pos=.2*(rand(floor(x)+234.)-.5);
    
    c=mask(c,door_color,rrect2(uv,vec2(door_pos,-.15),vec2(.08,.1),.01,.0,E));
    c=mask(c,vec3(.5,.5,.0),circle(uv,vec2(door_pos+.02,-.15),.02,E));
    
    float mask_height=height-.165;
    mask_height-=mod(mask_height,.1);
    float window_mask=rect(uv,vec2(.0,mask_height*.5-.04),vec2(.3,mask_height),.0,E);
    
    vec2 uv2=mod(uv+.05,.1)-.05;
    float light=rand(floor(x)+432.+floor((uv.x+.05)*10.)*233.+floor((uv.y+.05)*10.)*523.);
    c=mask(c,light<.3?vec3(.1,.1,.1):vec3(.7,.7,.5),window_mask*rrect(uv2,vec2(.0,-.0),vec2(.07,.07),.01,.0,E));
    return c;
}

vec3 dude(vec2 uv,vec3 c,float t0){
    const vec2 LEG0[8]=vec2[](vec2(+.00,-.10),vec2(+.00,-.12),vec2(+.00,-.09),vec2(+.00,-.08),vec2(+.00,-.10),vec2(+.00,-.12),vec2(+.00,-.09),vec2(+.00,-.08));
    const vec2 LEG1[8]=vec2[](vec2(+.06,-.20),vec2(+.06,-.20),vec2(-.01,-.20),vec2(-.03,-.20),vec2(-.03,-.20),vec2(-.03,-.20),vec2(+.02,-.18),vec2(+.06,-.15));
    const vec2 LEG2[8]=vec2[](vec2(+.11,-.30),vec2(+.06,-.30),vec2(-.02,-.30),vec2(-.06,-.30),vec2(-.09,-.28),vec2(-.12,-.25),vec2(-.04,-.20),vec2(+.01,-.25));
    const vec2 ARM0[8]=vec2[](vec2(-.00,+.07),vec2(-.01,+.05),vec2(+.01,+.08),vec2(+.02,+.09),vec2(+.03,+.07),vec2(+.03,+.05),vec2(+.02,+.08),vec2(+.01,+.09));
    const vec2 ARM1[8]=vec2[](vec2(-.05,+.02),vec2(-.07,+.02),vec2(+.00,+.00),vec2(+.03,+.02),vec2(+.04,+.01),vec2(+.05,+.01),vec2(+.00,+.01),vec2(-.04,+.02));
    const vec2 ARM2[8]=vec2[](vec2(-.06,-.06),vec2(-.08,-.05),vec2(+.00,-.07),vec2(+.05,-.07),vec2(+.07,-.07),vec2(+.09,-.06),vec2(+.01,-.06),vec2(-.04,-.06));
    
    float t=mod(t0,.8);
    float t2=t*10.;
    float t3=mod(t,.1)*10.;
    
    int ti1=int(t2);
    int ti1_next=int(mod(t2+1.,8.));
    
    int ti2=int(mod(t2+4.,8.));
    int ti2_next=int(mod(t2+5.,8.));
    
    vec2 l10=(1.-t3)*LEG0[ti1]+t3*LEG0[ti1_next];
    vec2 l11=(1.-t3)*LEG1[ti1]+t3*LEG1[ti1_next];
    vec2 l12=(1.-t3)*LEG2[ti1]+t3*LEG2[ti1_next];
    
    vec2 l20=(1.-t3)*LEG0[ti1]+t3*LEG0[ti1_next];
    vec2 l21=(1.-t3)*LEG1[ti2]+t3*LEG1[ti2_next];
    vec2 l22=(1.-t3)*LEG2[ti2]+t3*LEG2[ti2_next];
    
    vec2 a10=(1.-t3)*ARM0[ti1]+t3*ARM0[ti1_next];
    vec2 a11=(1.-t3)*ARM1[ti1]+t3*ARM1[ti1_next];
    vec2 a12=(1.-t3)*ARM2[ti1]+t3*ARM2[ti1_next];
    
    vec2 a20=(1.-t3)*ARM0[ti2]+t3*ARM0[ti2_next];
    vec2 a21=(1.-t3)*ARM1[ti2]+t3*ARM1[ti2_next];
    vec2 a22=(1.-t3)*ARM2[ti2]+t3*ARM2[ti2_next];
    
    vec3 c0=color(t0*.2);
    
    c=mask(c,.4*c0,line(uv,l20,l21,.05,E));
    c=mask(c,.4*c0,line(uv,l21,l22,.05,E));
    
    c=mask(c,.4*c0,line(uv,a20,a21,.04,E));
    c=mask(c,.4*c0,line(uv,a21,a22,.04,E));
    
    c=mask(c,.5*c0,line(uv,l10+vec2(.0,.01),l10+vec2(.01,.15),.1,E));
    
    c=mask(c,.5*c0,line(uv,l10,l11,.05,E));
    c=mask(c,.5*c0,line(uv,l11,l12,.05,E));
    
    c=mask(c,.6*c0,line(uv,a10,a11,.04,E));
    c=mask(c,.6*c0,line(uv,a11,a12,.04,E));
    
    c=mask(c,.5*c0,circle(uv,l10+vec2(.015,.25),.1,E));
    
    return c;
}

vec3 lamp(vec2 uv,vec3 c){
    
    c=mask(c,vec3(.05),rrect2(uv,vec2(.25,-.1),vec2(.03,.25),.01,.0,E));
    
    float light_mask=n(
        triangle(uv,vec2(.23,-.1),vec2(.2,.25),.0,.01)+
        rect(uv,vec2(.25,-.1),vec2(.04,.25),.0,.01)+
        triangle(uv,vec2(.27,-.1),vec2(.2,.25),.0,.01)+
        ellipse(uv,vec2(.25,-.23),vec2(.24,.1),.01)
    );
    
    c=mask(c,vec3(.8,.8,.0),light_mask*.5*n(uv.y*2.5+.6));
    c=mask(c,vec3(.05),rrect2(uv,vec2(.25,.02),vec2(.06,.02),.01,.0,E));
    
    return c;
}

vec3 road(vec2 uv,vec3 c){
    c=mask(c,vec3(.2),smoothstep(E,-E,uv.y+.2));
    c=mask(c,vec3(.05),smoothstep(E,-E,uv.y+.24));
    c=mask(c,vec3(.1),smoothstep(E,-E,uv.y+.25));
    c=mask(c,vec3(.2),smoothstep(E,-E,uv.y+.38));
    
    c=mask(c,vec3(.6),rrect(uv,vec2(.0,-.31),vec2(.05,.01),.0,.0,E));
    
    return c;
}

vec3 sky(vec2 uv,float x){
    vec3 c=vec3(0,.3-.5*uv.y,.5);
    
    float t=x*.1;
    
    const float size=.05;
    vec2 uv2=mod(uv+vec2(t,.0),size);
    float r1=rand(floor((uv.x+t+size)*20.)*223.+floor((uv.y+10.+size)*20.)*523.);
    float r2=rand(floor((uv.x+t+size)*20.)*523.+floor((uv.y+10.+size)*20.)*823.);
    float r3=rand(floor((uv.x+t+size)*20.)*923.+floor((uv.y+10.+size)*20.)*323.);
    if(r3<.1){
        
        float star=n(uv.y*2.)*n(
            circle(mod(uv2,.05),vec2(size*.5+size*.4*(r1-.5),size*.5+size*.4*(r2-.5)),.002,E)+
            circle(mod(uv2,.05),vec2(size*.5+size*.4*(r1-.5),size*.5+size*.4*(r2-.5)),.005,.015)
        );
        
        c=mask(c,vec3(.9,.9,.7),star);
    }
    
    c=mask(c,vec3(.9,.9,.7),n(circle(uv,vec2(-.6,.25),.1,E)+circle(uv,vec2(-.6,.25),.11,.02)));
    
    return c;
}

vec3 image(vec2 uv,float t){
    float bg_time=uv.x+t*.4;
    
    vec3 c=sky(uv,t);
    
    vec2 uv1=vec2(mod(bg_time,.2),uv.y);
    c=road(uv1,c);
    
    vec2 uv2=vec2(mod(bg_time,.32),uv.y);
    c=building(bg_time/.32,uv2-vec2(.15,.0),c);
    
    vec2 uv3=vec2(mod(bg_time,.5),uv.y);
    c=lamp(uv3,c);
    
    c=dude(uv+vec2(.0,.1),c,t*.6);
    
    return c;
}

vec3 colorShiftImage(vec2 uv,float t0,float t1,float size){
    vec3 c1=image(uv+vec2(size*sin(t1),size*cos(t1)),t0);
    vec3 c2=image(uv+vec2(size*sin(t1+2.),size*cos(t1+2.)),t0);
    vec3 c3=image(uv+vec2(size*sin(t1+4.),size*cos(t1+4.)),t0);
    
    return vec3(c1.x,c2.y,c3.z);
}

void main(){
    vec2 uv=(gl_FragCoord.xy/iResolution.xy-.5);
    uv.x*=iResolution.x/iResolution.y;
    
    vec3 c=colorShiftImage(uv,iTime*.5,iTime*5.,.00);
    
    gl_FragColor=vec4(c,1.);
}