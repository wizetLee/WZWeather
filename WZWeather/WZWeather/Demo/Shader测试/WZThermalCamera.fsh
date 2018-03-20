
//    partly adapted from http://coding-experiments.blogspot.com/2010/10/thermal-vision-pixel-shader.html

uniform sampler2D inputImageTexture;
varying highp vec2 textureCoordinate;      

varying highp vec2 left_coord;
varying highp vec2 right_coord;
varying highp vec2 above_coord;
varying highp vec2 below_coord;

varying highp vec2 lefta_coord;
varying highp vec2 righta_coord;
varying highp vec2 leftb_coord;
varying highp vec2 rightb_coord;


void main ()    {
//    lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
//    gl_FragColor = textureColor;
   
   highp vec4 colors[9];
    //    8 color stages with variable ranges to get this to look right
    //    black, purple, blue, cyan, green, yellow, orange, red, red
    colors[0] = vec4(0.0,0.0,0.0,1.0);
    colors[1] = vec4(0.272,0.0,0.4,1.0);
    colors[2] = vec4(0.0,0.0,1.0,1.0);
    colors[3] = vec4(0.0,1.0,1.0,1.0);
    colors[4] = vec4(0.0,1.0,0.0,1.0);
    colors[5] = vec4(0.0,1.0,0.0,1.0);
    colors[6] = vec4(1.0,1.0,0.0,1.0);
    colors[7] = vec4(1.0,0.5,0.0,1.0);
    colors[8] = vec4(1.0,0.0,0.0,1.0);
    
   highp vec4 color = texture2D(inputImageTexture, textureCoordinate);
   highp vec4 colorL = texture2D(inputImageTexture, left_coord);
  highp  vec4 colorR = texture2D(inputImageTexture, right_coord);
  highp  vec4 colorA = texture2D(inputImageTexture, above_coord);
  highp  vec4 colorB = texture2D(inputImageTexture, below_coord);
    
  highp  vec4 colorLA = texture2D(inputImageTexture, lefta_coord);
   highp vec4 colorRA = texture2D(inputImageTexture, righta_coord);
   highp vec4 colorLB = texture2D(inputImageTexture, leftb_coord);
  highp  vec4 colorRB = texture2D(inputImageTexture, rightb_coord);
    
  highp  vec4 avg = (color + colorL + colorR + colorA + colorB + colorLA + colorRA + colorLB + colorRB) / 9.0;
    
    //float lum = (avg.r+avg.g+avg.b)/3.0;
   highp float lum = dot(vec3(0.30, 0.59, 0.11), avg.rgb);
    lum = pow(lum,1.4);
    
   highp int ix = 0;
   highp float range = 1.0 / 8.0;
    
    //    orange to red
  highp  vec4 startColor;
   highp vec4 endColor;
    if (lum > range * 7.0)    {
        startColor = colors[7];
        endColor = colors[8];
        ix = 7;
    }
    //    yellow to orange
    else if (lum > range * 6.0)    {
        startColor = colors[6];
        endColor = colors[7];
        ix = 6;
    }
    //    green to yellow
    else if (lum > range * 5.0)    {
        startColor = colors[5];
        endColor = colors[6];
        ix = 5;
    }
    //    green to green
    else if (lum > range * 4.0)    {
        startColor = colors[4];
        endColor = colors[5];
        ix = 4;
    }
    //    cyan to green
    else if (lum > range * 3.0)    {
        startColor = colors[3];
        endColor = colors[4];
        ix = 3;
    }
    //    blue to cyan
    else if (lum > range * 2.0)    {
        startColor = colors[2];
        endColor = colors[3];
        ix = 2;
    }
    // purple to blue
    else if (lum > range)    {
        startColor = colors[1];
        endColor = colors[2];
        ix = 1;
    }
    else    {
        startColor = colors[0];
        endColor = colors[1];
    }
    
   highp vec4 thermal = mix(startColor,endColor,(lum-float(ix)*range)/range);
    gl_FragColor = thermal;
    
}
