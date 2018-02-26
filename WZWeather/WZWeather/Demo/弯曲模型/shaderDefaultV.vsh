
attribute vec4 position;
attribute vec2 textureCoordinate;

varying lowp vec2 varyTextCoord;

void main() {
    varyTextCoord = textureCoordinate;
    gl_Position = position;
}
