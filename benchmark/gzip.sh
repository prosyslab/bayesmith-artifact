

source env.sh
set -e
cd /$TMP
python3 -m tclib download https://ftp.gnu.org/gnu/gzip/gzip-1.2.4a.tar.gz gzip-1.2.4a.tar.gz e78be3088933a992b8167ff83eedcf01c989f368dc38748d76a1a25e38c3d519
#python3 -m tclib download https://ftp.gnu.org/gnu/wget/wget-1.15.tar.gz  wget-1.15.tar.gz 52126be8cf1bddd7536886e74c053ad7d0ed2aa89b4b630f76785bac21695fcd
F=gzip-1.2.4a
rm -rf $F
tar -xzf $F.tar.gz
pushd /$TMP/$F
INC=$(find -name "*.h" -printf '-I%h\n'|sort -u|tr '\n' ' ')
docker run --mount type=bind,source=/dev/shm/$F/,target=/src sparrow:latest bash -c "cd /src;./configure;"
find . -name '*.c'|xargs -I{} -P 16 $CLANG_TIDY {} --quiet -fix-errors -checks="-*,readability-braces-around-statements" -- $INC 2>&1 #|grep error:
docker run --mount type=bind,source=/dev/shm/$F/,target=/src sparrow:latest bash -c "cd /src;smake --init;smake"
sudo chown -R ubuntu:ubuntu .
ls sparrow
cd sparrow
#sparrow -il *.i>wget.merged.c
popd
