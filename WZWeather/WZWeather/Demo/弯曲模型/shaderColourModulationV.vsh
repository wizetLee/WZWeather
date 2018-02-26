attribute vec4 position;
attribute vec2 textureCoordinate;
attribute vec2 secondTextureCoordinate;

varying vec2 textureCoordinatePort;
varying vec2 secondTextureCoordinatePort;

void main()
{
    textureCoordinatePort = textureCoordinate;
    secondTextureCoordinatePort = secondTextureCoordinate;
    
    gl_Position = position;
}
