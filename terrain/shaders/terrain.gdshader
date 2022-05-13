shader_type spatial;
render_mode unshaded;

void vertex() {
  VERTEX.y += cos(VERTEX.x) * sin(VERTEX.z);
}