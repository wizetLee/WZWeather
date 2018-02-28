
precision highp float;

varying highp vec2 textureCoordinatePort;
varying highp vec2 secondTextureCoordinatePort;

uniform sampler2D sourceImage;
uniform sampler2D secondSourceImage;

uniform lowp float alpha;
uniform highp int blendType;

vec4 DifferenceBlend(vec4 secondSourceColor, vec4 sourceColor, float opacity)
{
    if(sourceColor.a > 0.0){
        
        sourceColor.rgb = clamp(sourceColor.rgb / sourceColor.a, 0.0, 1.0);
        highp vec3 result = abs(sourceColor.rgb - secondSourceColor.rgb);
        
        result = clamp(result, 0.0, 1.0);
        
        return vec4(mix(secondSourceColor.rgb, result, sourceColor.a * opacity), 1.0);
    }
    
    return secondSourceColor;
}

vec4 blendColor(vec4 base, vec4 overlay, int com, float opa)
{
    vec4 result;
    if (blendType == 26) {
        result = DifferenceBlend(base, overlay, opa);
    }
    return result;
}

void main()
{
    lowp vec4 sourceColor = texture2D(sourceImage, textureCoordinatePort);
    lowp vec4 secondSourceColor = texture2D(secondSourceImage, secondTextureCoordinatePort);
    
    gl_FragColor = blendColor(secondSourceColor, sourceColor, blendType, alpha);
    
}
