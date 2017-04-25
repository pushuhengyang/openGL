//#version 330 core
varying lowp vec2 vertexColor; // 从顶点着色器传来的输入变量（名称相同、类型相同）
uniform sampler2D courTexture;//纹理采样器
uniform sampler2D courTexture1;//同上
varying lowp vec3 frgBaseColor;
//out vec4 color; // 片段着色器输出的变量名可以任意命名，类型必须是vec4

void main()
{
//    gl_FragColor = texture2D(courTexture1, vertexColor)*vec4(frgBaseColor,1.0);
    gl_FragColor=mix(texture2D(courTexture, vertexColor),texture2D(courTexture1, vertexColor),0.7)*vec4(frgBaseColor,1.0);
}
