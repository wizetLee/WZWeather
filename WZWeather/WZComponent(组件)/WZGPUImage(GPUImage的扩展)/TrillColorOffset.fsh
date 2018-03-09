precision highp float;                          //预设浮点型的精度
varying highp vec2 textureCoordinate;           //坐标

uniform sampler2D inputImageTexture;            //纹理

uniform highp float enlargeWeight;              //扩大权重
highp float shadowWeight;                       //颜色偏移权重

//normal   red  green 颜色的偏移点
highp vec2 textureCoordinatePort;               //正常的
highp vec2 redTextureCoordinatePort;            //偏左上
highp vec2 greenTextureCoordinatePort;          //偏右下


void main()
{
    //0,0~1,1 映射到 weight,weight ~ 1-(weight), 1-(weight)  范围
    //enlargeWeight * 2.0 < 1
    highp float weight = clamp(enlargeWeight, 0.0, 0.4);//权重的取值范围 取值范围为[0, 0.4]
    textureCoordinatePort = vec2(weight + textureCoordinate.x * (1.0 - weight * 2.0/*左右余隙*/)
                                 ,weight + textureCoordinate.y * (1.0 - weight * 2.0/*上下余隙*/)) ;//正常位置 依靠enlargeWeight计算扩大权重
    shadowWeight = weight * 0.1;       //扩大的时候开始产生偏移。0.05（可以适度调节）
    redTextureCoordinatePort = vec2(textureCoordinatePort.x + shadowWeight
                                , textureCoordinatePort.y + shadowWeight);
    
    greenTextureCoordinatePort = vec2(textureCoordinatePort.x - shadowWeight
                                , textureCoordinatePort.y - shadowWeight);
    
    lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinatePort);
    
    lowp vec4 textureColorRed = vec4(texture2D(inputImageTexture, redTextureCoordinatePort).r , 0.0, 0.0, textureColor.a);
    
    lowp vec4 textureColorGreen = vec4(0.0 , texture2D(inputImageTexture,greenTextureCoordinatePort).g, texture2D(inputImageTexture,greenTextureCoordinatePort).b, textureColor.a);
    
    textureColor = vec4(max(max(textureColor.rgb
                                , textureColorRed.rgb)
                            , textureColorGreen.rgb)
                        , textureColor.a);
    
    gl_FragColor = textureColor;
}
