//precision highp float;

attribute vec4 position;                          //顶点坐标相同
attribute vec4 inputTextureCoordinate;            //纹理坐标
attribute vec4 position2;                          //顶点坐标相同
attribute vec4 inputTextureCoordinate2;           //纹理坐标

varying vec2 textureCoordinate;                   //传递给fsh
varying vec2 textureCoordinate2;                  //传递给fsh

uniform highp float progress;            //过渡进度
uniform lowp int type;                   //过渡类型


uniform mat4 transform;                     //翻转效果（使用了GLK的接口）

void main()
{
    
    
    
    
    textureCoordinate = inputTextureCoordinate.xy;
    textureCoordinate2 = inputTextureCoordinate2.xy;
    
    if (type == 111) {
        textureCoordinate = vec2(inputTextureCoordinate.x - progress, inputTextureCoordinate.y);
        textureCoordinate2 = vec2(inputTextureCoordinate2.x + 1.0 - progress, inputTextureCoordinate2.y);
    } else if (type == 222) {
        textureCoordinate = vec2(inputTextureCoordinate.x + progress, inputTextureCoordinate.y);
        textureCoordinate2 = vec2(inputTextureCoordinate2.x - 1.0 + progress, inputTextureCoordinate2.y);
    } else if (type == 333) {
        textureCoordinate = vec2(inputTextureCoordinate.x, inputTextureCoordinate.y - progress);
        textureCoordinate2 = vec2(inputTextureCoordinate2.x, inputTextureCoordinate2.y + 1.0 - progress);
    } else if (type == 444) {
        textureCoordinate = vec2(inputTextureCoordinate.x, inputTextureCoordinate.y + progress);
        textureCoordinate2 = vec2(inputTextureCoordinate2.x, inputTextureCoordinate2.y - 1.0 + progress);
    } else {
        
    }
    
    if (type == 1212) {
        gl_Position = transform * position;
    } else {
        gl_Position = position;
    }
    
}
