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

#define PI 3.1416
#define FAR 50.
#define MAX_RAY 92
#define MAX_REF 16
#define FOV 1.57
#define OBJ_MIN_D .01

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

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

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

float sphere(vec3 q,vec3 p,float r){
    return length(q-p)-r;
}

float plane(vec3 q,vec3 d,float offset){
    return dot(d,q)+offset;
}

float capsule(vec3 q,vec3 p1,vec3 p2,float r){
    vec3 ab1=p2-p1;
    vec3 ap1=q-p1;
    float t1=dot(ap1,ab1)/dot(ab1,ab1);
    t1=clamp(t1,0.,1.);
    vec3 c1=p1+t1*ab1;
    return length(q-c1)-r;
}

float torus(vec3 q,vec3 p,float r1,float r2){
    q-=p;
    float x=length(q.xz)-r1;
    return length(vec2(x,q.y))-r2;
}

float box(vec3 q,vec3 p,vec3 s){
    return length(max(abs(q-p)-s,0.));
}

float cyl(vec3 q,vec3 p1,vec3 p2,float r){
    vec3 ab2=p2-p1;
    vec3 ap2=q-p1;
    float t2=dot(ap2,ab2)/dot(ab2,ab2);
    vec3 c2=p1+t2*ab2;
    float d=length(q-c2)-r;
    float y=(abs(t2-.5)-.5)*length(ab2);
    float e=length(max(vec2(d,y),0.));
    float i=min(max(d,y),0.);
    return e+i;
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#define OBJ_COUNT 6

float objects[OBJ_COUNT]=float[](FAR,FAR,FAR,FAR,FAR,FAR);
vec3 objectsColor[OBJ_COUNT]=vec3[](vec3(1.),vec3(1.),vec3(1.),vec3(1.),vec3(1.),vec3(1.));
const float objectsRef[OBJ_COUNT]=float[](.1,.1,.1,.1,.1,.1);

void setObjects(vec3 q){
    
    vec3 pos=vec3(.0,.0,-iTime*2.);
    
    q-=pos;
    
    float seed=abs(floor(q.x))+abs(floor(q.y))*100.+abs(floor(q.z))*1000.;
    float diff=rand(seed)*2.*PI;
    
    objects[0]=sphere(mod(q,1.),.5+vec3(cos(iTime+diff+PI)*.1,.1,sin(iTime+diff+PI)*.1),.1);
    objects[1]=box(mod(q-vec3(cos(iTime+diff)*.1,-.1,sin(iTime+diff)*.1),1.),vec3(.5),vec3(.15));
    objects[2]=plane(q,vec3(.0,1.,.0),1.5);
    objects[3]=plane(q,vec3(.0,-1.,.0),1.5);
    objects[4]=plane(q,vec3(1.,.0,.0),1.5);
    objects[5]=plane(q,vec3(-1.,.0,.0),1.5);
}

void setObjectColors(vec3 q){
    
    vec3 pos=vec3(.0,.0,-iTime*2.);
    
    q-=pos;
    
    float seed=abs(floor(q.x))+abs(floor(q.y))*100.+abs(floor(q.z))*1000.;
    
    objectsColor[0]=col(rand(seed++));
    objectsColor[1]=col(rand(seed++));
    objectsColor[2]=col(rand(seed++));
    objectsColor[3]=col(rand(seed++));
    objectsColor[4]=col(rand(seed++));
    objectsColor[5]=col(rand(seed++));
}

float map(vec3 q){
    float d=FAR;
    
    setObjects(q);
    
    for(int i=0;i<OBJ_COUNT;i++)
    d=min(d,objects[i]);
    
    return d;
}

vec3 mapColor(vec3 q){
    setObjects(q);
    setObjectColors(q);
    
    vec3 c=vec3(.0);
    float mind=FAR;
    
    for(int i=0;i<OBJ_COUNT;i++){
        if(objects[i]<OBJ_MIN_D&&objects[i]<mind){
            c=objectsColor[i];
            mind=objects[i];
        }
    }
    
    return c;
}

float mapRef(vec3 q){
    setObjects(q);
    
    float ref=.0;
    float mind=FAR;
    
    for(int i=0;i<OBJ_COUNT;i++){
        if(objects[i]<OBJ_MIN_D&&objects[i]<mind){
            ref=objectsRef[i];
            mind=objects[i];
        }
    }
    
    return ref;
}

float rayMarch(vec3 ro,vec3 rd,int max_d){
    float t=0.,h;
    for(int i=0;i<max_d;i++){
        h=map(ro+rd*t);
        if(abs(h)<.001*(t*.25+1.)||t>FAR)break;
        t+=h*.8;
    }
    return t;
}

vec3 normal(vec3 p){
    const vec2 e=vec2(.0025,-.0025);
    return normalize(e.xyy*map(p+e.xyy)+e.yyx*map(p+e.yyx)+e.yxy*map(p+e.yxy)+e.xxx*map(p+e.xxx));
}

float occlusion(vec3 pos,vec3 nor)
{
    float sca=2.,occ=0.;
    for(int i=0;i<5;i++){
        
        float hr=.01+float(i)*.5/4.;
        float dd=map(nor*hr+pos);
        occ+=(hr-dd)*sca;
        sca*=.7;
    }
    return clamp(1.-occ,0.,1.);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

vec4 getHitColor(vec3 ro,vec3 rd,float t,vec3 lightPos){
    vec3 hit=ro+rd*t;
    vec3 norm=normal(hit);
    
    vec3 light=lightPos-hit;
    float lightDist=max(length(light),.001);
    float atten=1./(1.+lightDist*.125+lightDist*lightDist*.05);
    light/=lightDist;
    
    float occ=occlusion(hit,norm);
    
    float dif=clamp(dot(norm,light),0.,1.);
    dif=pow(dif,4.)*2.;
    float spe=pow(max(dot(reflect(-light,norm),-rd),0.),8.);
    
    vec3 color=mapColor(hit+rd*OBJ_MIN_D)*(dif+.35+vec3(.35,.45,.5)*spe)+vec3(.7,.9,1)*spe*spe;
    
    return vec4(color,atten*occ);
}

vec3 getColor(vec2 uv,vec3 ro,vec3 dir,vec3 lightPos){
    vec3 fwd=normalize(dir-ro);
    vec3 rgt=normalize(vec3(fwd.z,0,-fwd.x));
    vec3 up=(cross(fwd,rgt));
    
    vec3 rd=normalize(fwd+FOV*(uv.x*rgt+uv.y*up));
    
    float t=rayMarch(ro,rd,MAX_RAY);
    
    vec3 outColor=vec3(.0);
    
    if(t<FAR){
        vec3 hit=ro+rd*t;
        vec3 norm=normal(hit);
        vec4 color=getHitColor(ro,rd,t,lightPos);
        
        vec3 ref=reflect(rd,norm);
        float refQ=mapRef(hit+rd*OBJ_MIN_D);
        float t2=rayMarch(hit+ref*.1,ref,MAX_REF);
        vec4 color2=getHitColor(hit+ref*.1,ref,t2,lightPos);
        
        outColor=(color.xyz*(1.-refQ)+refQ*color2.xyz*color2.w)*color.w;
    }
    
    outColor=mix(min(outColor,1.),vec3(0.),1.-exp(-t*t/FAR/FAR*10.));
    
    return outColor;
}

void mainImage(out vec4 fragColor,in vec2 fragCoord){
    vec2 uv=(fragCoord.xy/iResolution.xy-.5);
    uv.x*=iResolution.x/iResolution.y;
    
    vec3 pos=vec3(.0,.0,.0);
    vec3 dir=vec3(.0,.0,1.);
    vec3 light=pos+vec3(.0,.0,1.);
    
    vec3 c=getColor(uv,pos,dir,light);
    
    fragColor=vec4(sqrt(c),1.);
}