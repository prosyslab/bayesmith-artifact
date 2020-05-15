rm -rf optipng-0.5.3-out
cp -r optipng-0.5.3 optipng-0.5.3-out

pushd optipng-0.5.3-out

find . -name '*.c'|xargs -I{} -P 8 clang-tidy-9 {} --quiet -fix -checks="readability-braces-around-statements" -- -I./src -I./lib/zlib -I./lib/libpng -I./lib/pngxtern
find . -name '*.c' \
#-exec sed -i -z 's/,\n/,/g' {} + \
-exec clang-format-9 -sort-includes=false -style="{BasedOnStyle: llvm,BinPackArguments: false,ColumnLimit: 0}" -i {} + \
#space in the style field is required

find . -regex '.*\(Makefile\|makefile.*\|configure\|mak\)' -exec sed -i 's/gcc/clang/g' {} + \
-exec sed -i 's/-O2/-O2 -fPIC/g' {} + \
-exec sed -i 's/-O3/-O3 -fPIC/g' {} + \
-exec sed -i 's/-s/-s -fsanitize=dataflow/g' {} + \
-exec sed -i 's/clang.mak/gcc.mak/g' {} + \
-exec sed -i 's/makefile.clang/makefile.gcc/g' {} +

cd src
make clean
../../smake --clean
../../smake --init
../../smake
cd sparrow/optipng
sparrow -il *.i>optipng.merged.c
cp optipng.merged.c ../../../../../../bingo-ci-experiment/benchmark/optipng-0.5.3/optipng-0.5.3.c
popd

pushd ../../bingo-ci-experiment/
./run.sh benchmark/optipng-0.5.3/optipng-0.5.3.c taint
./run.sh benchmark/optipng-0.5.3/optipng-0.5.3.c interval
