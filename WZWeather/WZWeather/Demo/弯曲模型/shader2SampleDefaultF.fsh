
varying lowp vec2 varyTextCoord;
varying lowp vec2 varyTextCoord2;

uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;

lowp vec4 LightenBlend(lowp vec4 secondSourceColor, lowp vec4 sourceColor, lowp float opacity)
{
    if(sourceColor.a > 0.0){
        sourceColor.rgb = clamp(sourceColor.rgb / sourceColor.a, 0.0, 1.0);
        
        mediump vec3 result = max(sourceColor.rgb, secondSourceColor.rgb);
        
        result = clamp(result, 0.0, 1.0);
        
        return  vec4(mix(secondSourceColor.rgb, result, sourceColor.a * opacity), 1.0);
    }
    
    return secondSourceColor;
}

lowp vec4 blendColor(lowp vec4 base,lowp vec4 overlay, int com, lowp float opa)
{
    lowp vec4 result = LightenBlend(base, overlay, opa);
    return result;
}

void main()
{
     lowp vec4 color1 =  texture2D(inputImageTexture, varyTextCoord);//左右颠倒
     lowp vec4 color2 =  texture2D(inputImageTexture2, varyTextCoord2);//左右颠倒.
    
    gl_FragColor = blendColor(color1, color2, 0, 1.0);
    
//    gl_FragColor = texture2D(texture, varyTextCoord);//左右颠倒
    //    gl_FragColor = texture2D(texture0, 1 - varyTextCoord);//上下颠倒
}
