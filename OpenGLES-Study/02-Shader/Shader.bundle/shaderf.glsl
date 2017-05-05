varying lowp vec2 coord;

uniform sampler2D grass;

void main() {
    gl_FragColor = texture2D(grass, coord);
}
