varying lowp vec2 varyTextCoord;

uniform sampler2D imageTexture;

void main() {
    gl_FragColor = texture2D(imageTexture, varyTextCoord);//左右颠倒
//    gl_FragColor = texture2D(texture0, 1 - varyTextCoord);//上下颠倒
}
