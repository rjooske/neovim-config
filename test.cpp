// Void to void
void foo();

void foo(int);

// Int and double to int
int foo(int, double);

int main() {
  foo();
  foo(0);
  foo(0, 2);
  return 0;
}
