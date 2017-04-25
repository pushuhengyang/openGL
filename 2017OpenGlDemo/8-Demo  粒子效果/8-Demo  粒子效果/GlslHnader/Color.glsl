uniform sampler2D       u_samplers2D;

void main()
{
    lowp vec4 textureColor = texture2D(u_samplers2D,
                                       gl_PointCoord);    
    gl_FragColor = textureColor;
}
