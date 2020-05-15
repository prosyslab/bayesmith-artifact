source env.sh
set -e
cd /$TMP
python3 -m tclib download https://ftp.gnu.org/gnu/wget/wget-1.19.5.tar.gz  wget-1.19.5.tar.gz
#python3 -m tclib download https://ftp.gnu.org/gnu/wget/wget-1.15.tar.gz  wget-1.15.tar.gz 52126be8cf1bddd7536886e74c053ad7d0ed2aa89b4b630f76785bac21695fcd
VER=1.19.5
sudo rm -rf wget-$VER
tar -xzf wget-$VER.tar.gz
pushd /$TMP/wget-$VER
INC=$(find -name "*.h" -printf '-I%h\n'|sort -u|tr '\n' ' ')
docker run --mount type=bind,source=/dev/shm/wget-$VER/,target=/src sparrow:latest bash -c "cd /src;./configure --with-ssl=openssl;"
#find . -name '*.c'|xargs -I{} -P 16 $CLANG_TIDY {} --quiet -fix-errors -checks="-*,readability-braces-around-statements" -- $INC 2>&1 #|grep error:
docker run --mount type=bind,source=/dev/shm/wget-$VER/,target=/src sparrow:latest bash -c "cd /src;smake --init;smake"
sudo chown -R ubuntu:ubuntu .
ls sparrow
cd sparrow/src
#sparrow -il *.i>wget.merged.c
popd
 