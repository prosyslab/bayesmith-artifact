int fread(void *ptr, int size, int nmemb, void *stream);

void read(void *buffer, void *fp) {
  fread(buffer, 256, fp);
  return;
}

int global;

int main() {
  void *fp;
  char buffer[256];
  read(buffer, fp);
  int a = 0;
  if(!fp)
    a++;
  int x = buffer[0] * 4;
  buffer[256] = 0;
  void *p = malloc(x);
  *(p + x) = 0;
  return 0;
}
