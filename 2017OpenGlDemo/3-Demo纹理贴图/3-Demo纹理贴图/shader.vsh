attribute vec3 Position; //位置
attribute vec2 textCoordinate;  //纹理
attribute vec3 baseColor;  //颜色
varying lowp vec2 vertexColor;
varying lowp vec3 frgBaseColor;


void main(){
    gl_Position =  vec4(Position,1.0);
    vertexColor = textCoordinate;
    frgBaseColor =baseColor;
}




