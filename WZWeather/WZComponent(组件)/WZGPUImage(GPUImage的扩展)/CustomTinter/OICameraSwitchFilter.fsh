varying highp vec2 textureCoordinate1;
varying highp vec2 textureCoordinate2;
//纹理做坐标

uniform sampler2D firstTexture;
uniform sampler2D secondTexture;
//采样器的2D纹理

uniform mediump float index;//0~1
uniform lowp int closewise; //0从左到右; 1从右到左， 2从下到上，3从上到下

void main()
{
    mediump vec4 firstTextureColor = texture2D(firstTexture, textureCoordinate1);
    mediump vec4 secondTextureColor = texture2D(secondTexture, textureCoordinate2);
    
     // 局部滤镜效果
//    if (abs(textureCoordinate1.x - index) < 0.0015) {
//        gl_FragColor = vec4(vec3(0.5), 1.0);
//        return;
//    }
//    if (index > 0.3) {
//        
//        if (index - textureCoordinate1.x > 0.003 && index - textureCoordinate1.x < 0.3-0.003) {
//            gl_FragColor = secondTextureColor;
//            return;
//        }
//        
//        if ((index - textureCoordinate1.x < (0.0015+0.3)) && (index - textureCoordinate1.x > (0.3-0.0015))) {
//            gl_FragColor = vec4(vec3(0.5), 1.0);
//            return;
//        }
//    
//        if (index - textureCoordinate1.x > (0.3-0.0015)) {
//            gl_FragColor = firstTextureColor;
//            return;
//        }
//    }
    
    if (closewise == 0) {
        //左到右
        if (textureCoordinate1.x < index) {
            gl_FragColor = secondTextureColor;
        } else {
            gl_FragColor = firstTextureColor;
        }
    } else if (closewise == 1) {
        //右到左
        if ((1.0 - textureCoordinate1.x) < index) {
            gl_FragColor = secondTextureColor;
        } else {
            gl_FragColor = firstTextureColor;
        }
    } else if (closewise == 2) {
        //从下到上
        if (textureCoordinate1.y< index) {
            gl_FragColor = secondTextureColor;
        } else {
            gl_FragColor = firstTextureColor;
        }
    } else if (closewise == 3) {
        //从上到下
        if ((1.0 - textureCoordinate1.y) < index) {
            gl_FragColor = secondTextureColor;
        } else {
            gl_FragColor = firstTextureColor;
        }
    }
    
}

