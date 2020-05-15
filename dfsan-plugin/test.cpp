#include<stdio.h>
#include <sanitizer/dfsan_interface.h>
void dfsan_dummy(){
	int i;
	dfsan_label i_label = dfsan_create_label("i", 0);
	dfsan_set_label(i_label, &i, sizeof(i));
}
void gogo(){
	puts("hello");

}
int test(int i,int j){
	printf("%d\n",i+j);
	return i+j;
}
int main(){
	int i=3,j=4;
	test(i,j);
}