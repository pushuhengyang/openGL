attribute vec3 a_emissionPosition; //位置
attribute vec3 texCoords;//底色
uniform mat4 u_mvpMatrix;  //变换矩阵
varying lowp vec3 vertexColor;

attribute vec2 textCoordinate;  //纹理
varying lowp vec2 vertexCood;


void main(){

    gl_Position =vec4(a_emissionPosition,1.0);
    vertexColor = texCoords;
    vertexCood =vec2(textCoordinate.x,1.0-textCoordinate.y);
}
