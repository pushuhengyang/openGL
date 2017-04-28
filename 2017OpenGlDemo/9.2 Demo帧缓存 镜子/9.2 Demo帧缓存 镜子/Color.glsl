uniform sampler2D       u_samplers2D;
varying lowp vec3 vertexColor;
varying lowp vec2 vertexCood;

void main()
{
    lowp vec4 textureColor = texture2D(u_samplers2D,
                                       vertexCood);
    gl_FragColor = textureColor*vec4(vertexColor,1.0);
}
