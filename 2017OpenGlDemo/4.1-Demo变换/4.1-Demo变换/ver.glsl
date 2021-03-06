attribute vec3 Position;
attribute vec2 textCoordinate;
attribute vec3 baseColor;
varying lowp vec2 vertexColor;
varying lowp vec3 frgBaseColor;
uniform mat4 transform;

void main(){
    
    gl_Position = transform*vec4(Position,1.0);
    vertexColor = vec2(textCoordinate.x,1.0-textCoordinate.y);
    frgBaseColor =baseColor;
}
