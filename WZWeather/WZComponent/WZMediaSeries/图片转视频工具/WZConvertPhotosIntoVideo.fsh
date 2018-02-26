//precision highp float;

varying highp vec2 textureCoordinate;       // XY坐标
varying highp vec2 textureCoordinate2;

uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
//uniform lowp float mixturePercent;


uniform highp float progress;            //过渡进度
uniform lowp int type;                   //过渡类型


//百叶窗（以及渐变的）----------------------------------------------
const int kMaxUndulatedCount = 10;                     //个人设置：最大的波动范围为10个
const int kUndulatedCoupleCount = ((kMaxUndulatedCount * 2 + 1) * 2);//“波动对”的总数目 = (n * 2 + 1) * 2
uniform int undulatedCount; //传入的值
uniform int undulatedCoupleCount;
uniform highp float undulatedCouple[kUndulatedCoupleCount];
uniform highp float undulatedCoordinateOffset;
//百叶窗----------------------------------------------

void main()
{
    lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);

    if (type == 1) {                //溶解
        lowp vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate2);
        if (progress < 0.0) {
//            textureColor.rgb = mix(textureColor.rgb, textureColor2.rgb, (1.0 - textureColor.a));
        } else if (progress > 1.0) {
            textureColor.rgb = textureColor2.rgb;
        } else {
            textureColor.rgb = mix(textureColor.rgb, textureColor2.rgb, progress);
        }
        textureColor.a = max(textureColor.a, textureColor2.a);
       
    } else if (type == 2) {         //闪黑
        lowp vec4 blendColor = vec4(vec3(0.0), 1.0);//黑色 alpha为1
        textureColor = vec4(mix(textureColor.rgb, blendColor.rgb, progress), 1.0);
    } else if (type == 3) {        //闪白
        lowp vec4 blendColor = vec4(vec3(1.0), 1.0);//白色 alpha为1
        textureColor = vec4(mix(textureColor.rgb, blendColor.rgb, progress), 1.0);
    } else if (type == 4) {       //模糊--------------------------------------------------------------------------------------------------------------------------------------------

    } else if (type == 5) {     //抹 L -> R
        //挤压
        if ((1.0 - textureCoordinate2.x) > progress) {
            textureColor = texture2D(inputImageTexture2, textureCoordinate2);
        }
    } else if (type == 6) {     //抹 R -> L
        if (textureCoordinate2.x > progress) {
            textureColor = texture2D(inputImageTexture2, textureCoordinate2);
        }
    } else if (type == 7) {     //抹 T -> B
        if ((1.0 - textureCoordinate2.y) > progress) {
            textureColor = texture2D(inputImageTexture2, textureCoordinate2);
        }
    } else if (type == 8) {     //抹 B -> T
        if (textureCoordinate2.y > progress) {
            textureColor = texture2D(inputImageTexture2, textureCoordinate2);
        }
    } else if (type == 9) {     //挤压 L -> R
        if (textureCoordinate.x >= 0.0) {
            textureColor = texture2D(inputImageTexture, textureCoordinate);
        } else {
            textureColor = texture2D(inputImageTexture2, textureCoordinate2);
        }
    } else if (type == 10) {    //挤压 R -> L
        if (textureCoordinate.x <=  1.0) {
            textureColor = texture2D(inputImageTexture, textureCoordinate);
        } else {
            textureColor = texture2D(inputImageTexture, textureCoordinate2);
        }
    } else if (type == 11) {    //挤压 T -> B
        if (textureCoordinate.y >= 0.0) {
            textureColor = texture2D(inputImageTexture, textureCoordinate);
        } else {
            textureColor = texture2D(inputImageTexture2, textureCoordinate2);
        }
    } else if (type == 12) {    //挤压 B -> T
        if (textureCoordinate.y <= 1.0) {
            textureColor = texture2D(inputImageTexture, textureCoordinate);
        } else {
            textureColor = texture2D(inputImageTexture2, textureCoordinate2);
        }
    } else if (type == 13) {        //翻转
       
    } else if (type == 14 || type == 15) {        //百叶窗
        int odevity = 0;
        for (int i = 0; i < undulatedCoupleCount; (i = i+2)) {
            if (odevity == 0) {
                //底层
                if (undulatedCouple[i]  < textureCoordinate.y
                    && undulatedCouple[i + 1] > textureCoordinate.y) {
                    textureColor = texture2D(inputImageTexture2, textureCoordinate2);
                    odevity = 0;
                    break;
                }
                odevity++;
            } else {
                //表层
                if (undulatedCouple[i]  < textureCoordinate.y
                    && undulatedCouple[i + 1] > textureCoordinate.y) {
                    textureColor = texture2D(inputImageTexture, textureCoordinate);
                    odevity = 0;
                    break;
                }
                odevity--;
            }
        }
    } else if (type == 15) {
        
    } else if (type == 16) {
        
    } else if (type == 17) {
        
    } else if (type == 18) {
        
    } else if (type == 19) {
        
    } else if (type == 20) {
/**
      |
 4    |    1
 ---------------
 3    |    2
      |
 **/
        highp float mappingX = textureCoordinate.x - 0.500000;//这里有一个坑就是不要用lowp类型，不然精度不够.....
        highp float mappingY = -(textureCoordinate.y - 0.500000);//Y轴上，openGL的坐标系和屏幕坐标系是相反的。
        if (progress < 0.25) {
            if (mappingX >= 0.0 && mappingY >= 0.0) {
                
                highp float tmpProgress = progress * 4.0;
                highp float tmpX1 = tmpProgress;
                highp float tmpY1 = -tmpX1 + 1.0;
                
                if (mappingX * tmpY1 > mappingY * tmpX1 ) {
                    textureColor = texture2D(inputImageTexture, textureCoordinate);
                } else {
                    textureColor = texture2D(inputImageTexture2, textureCoordinate2);
                }
            }
            
        } else if (progress < 0.50) {
            if (mappingX >= 0.0 && mappingY >= 0.0) {
                textureColor = texture2D(inputImageTexture2, textureCoordinate2);
            } else if (mappingX >= 0.0 && mappingY <= 0.0) {
                
                highp float tmpProgress = 1.0 - (progress - 0.25) * 4.0;
                highp float tmpX1 = tmpProgress;
                highp float tmpY1 = tmpX1 - 1.0;
                
                if (mappingX * tmpY1 > mappingY * tmpX1 ) {
                    textureColor = texture2D(inputImageTexture, textureCoordinate);
                } else {
                    textureColor = texture2D(inputImageTexture2, textureCoordinate2);
                }
            }
        } else if (progress < 0.75) {
            if (mappingX >= 0.0) {
                textureColor = texture2D(inputImageTexture2, textureCoordinate2);
            } else if(mappingY <= 0.0) {
                highp float tmpProgress = (progress - 0.50) * 4.0;
                highp float tmpX1 = -tmpProgress;
                highp float tmpY1 = -tmpX1 - 1.0;
                if (mappingX * tmpY1 > mappingY * tmpX1 ) {
                    textureColor = texture2D(inputImageTexture, textureCoordinate);
                } else {
                    textureColor = texture2D(inputImageTexture2, textureCoordinate2);
                }
            }
        } else {
            if (mappingX >= 0.0) {
                textureColor = texture2D(inputImageTexture2, textureCoordinate2);
            } else if(mappingY <= 0.0) {
                textureColor = texture2D(inputImageTexture2, textureCoordinate2);
            } else {
                highp float tmpProgress = 1.0 - (progress - 0.75) * 4.0;
                highp float tmpX1 = -tmpProgress;
                highp float tmpY1 = tmpX1 + 1.0;
                
                if (mappingX * tmpY1 > mappingY * tmpX1) {
                    textureColor = texture2D(inputImageTexture, textureCoordinate);
                } else {
                    textureColor = texture2D(inputImageTexture2, textureCoordinate2);
                }
            }
        }
    } else if (type == 21) {
        
    } else if (type == 22) {
        
    } else if (type == 23) {
        
    }
//    gl_FragColor = mix(textureColor, textureColor2, 0);
    
    
    
    gl_FragColor = textureColor;
}
