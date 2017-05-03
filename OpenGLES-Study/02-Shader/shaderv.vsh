attribute vec4 position;
attribute vec2 texCoord;
uniform mat4 matrix;
varying lowp vec2 coord;

void main() {
    coord = texCoord;
    vec4 vPosition = position;
    vPosition = vPosition * matrix;
    gl_Position = vPosition;
}
