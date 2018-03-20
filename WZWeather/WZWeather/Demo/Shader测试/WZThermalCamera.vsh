
attribute highp vec4 position;                          //顶点坐标相同
attribute highp vec4 inputTextureCoordinate;            //纹理坐标
varying highp vec2 textureCoordinate;       // XY坐标

varying highp vec2 left_coord;
varying highp vec2 right_coord;
varying highp vec2 above_coord;
varying highp vec2 below_coord;

varying highp vec2 lefta_coord;
varying highp vec2 righta_coord;
varying highp vec2 leftb_coord;
varying highp vec2 rightb_coord;


void main()
{
    textureCoordinate = inputTextureCoordinate.xy;
    
    highp vec2 texc = inputTextureCoordinate.xy;
//    vec2 d = 1.0/RENDERSIZE;
    highp vec2 d = vec2(0.0001, 0.0001);
    
    left_coord = clamp(vec2(texc.xy + vec2(-d.x , 0)),0.0,1.0);
    right_coord = clamp(vec2(texc.xy + vec2(d.x , 0)),0.0,1.0);
    above_coord = clamp(vec2(texc.xy + vec2(0,d.y)),0.0,1.0);
    below_coord = clamp(vec2(texc.xy + vec2(0,-d.y)),0.0,1.0);
    
    lefta_coord = clamp(vec2(texc.xy + vec2(-d.x , d.x)),0.0,1.0);
    righta_coord = clamp(vec2(texc.xy + vec2(d.x , d.x)),0.0,1.0);
    leftb_coord = clamp(vec2(texc.xy + vec2(-d.x , -d.x)),0.0,1.0);
    rightb_coord = clamp(vec2(texc.xy + vec2(d.x , -d.x)),0.0,1.0);
    gl_Position = position;
    
}
