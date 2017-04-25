attribute vec3 a_emissionPosition; //位置

attribute vec2 a_size;  //大小 和 Fade持续时间  size = GLKVector2Make(aSize, aDuration);
attribute vec2 a_emissionAndDeathTimes; //发射时间 和 消失时间


// UNIFORMS
uniform mat4 u_mvpMatrix;
// Varyings
varying lowp float      v_particleOpacity; //粒子 不透明度


void main(){
    
    
    gl_Position =u_mvpMatrix*vec4(a_emissionPosition,1.0);
    gl_PointSize = 40.0;
    
}
