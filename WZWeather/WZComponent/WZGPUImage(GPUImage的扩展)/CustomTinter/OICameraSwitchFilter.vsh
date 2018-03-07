
attribute vec4 position;

attribute vec2 firstTextureCoordinate;
attribute vec2 secondTextureCoordinate;

varying vec2 textureCoordinate1;
varying vec2 textureCoordinate2;

void main()
{
    textureCoordinate1 = firstTextureCoordinate;
    textureCoordinate2 = secondTextureCoordinate;
    gl_Position = position;
}
