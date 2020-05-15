source env.sh
set -e
cd /$TMP
python3 -m tclib download https://curl.haxx.se/download/curl-7.69.1.tar.gz curl-7.69.1.tar.gz 01ae0c123dee45b01bbaef94c0bc00ed2aec89cb2ee0fd598e0d302a6b5e0a98
#python3 -m tclib download https://ftp.gnu.org/gnu/wget/wget-1.15.tar.gz  wget-1.15.tar.gz 52126be8cf1bddd7536886e74c053ad7d0ed2aa89b4b630f76785bac21695fcd
F=curl-7.69.1
sudo rm -rf $F
tar -xzf $F.tar.gz
pushd /$TMP/$F
./configure
INC=$(find -name "*.h" -printf '-I%h\n'|sort -u|tr '\n' ' ')
#find . -name "*.c"|xargs -I{} -P 8 $CLANG_TIDY {}  -fix-errors -checks="-*,readability-braces-around-statements" -- $INC -Iinclude 2>&1 #|grep error:'
make -j8
popd
