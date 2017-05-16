attribute vec3 Position; //位置
attribute vec2 textCoordinate;  //纹理
attribute vec3 baseColor;  //颜色
varying lowp vec2 vertexColor;
varying lowp vec3 frgBaseColor;

uniform vec2 offsets[100];


void main(){
    
    
    vec2 offset = offsets[gl_InstanceID];

    gl_Position =  vec4(Position+vec3(offset,0.0),1.0);
    vertexColor = vec2(textCoordinate.x,1.0-textCoordinate.y);
    frgBaseColor =baseColor;
}




