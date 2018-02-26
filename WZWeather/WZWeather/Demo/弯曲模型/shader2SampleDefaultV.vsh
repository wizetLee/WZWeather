

attribute vec4 position;
attribute vec2 textureCoordinate;
attribute vec2 textureCoordinate2;

varying lowp vec2 varyTextCoord;
varying lowp vec2 varyTextCoord2;

uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;

void main() {
    varyTextCoord = textureCoordinate;
    varyTextCoord2 = textureCoordinate2;
    gl_Position = position;
}
