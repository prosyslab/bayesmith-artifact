set -e
clear
make
#cp /home/ubuntu/plwork/PL-working/dfsan-inject/task.txt /tmp
#time clang-11  -fsanitize=dataflow  -Xclang -load -Xclang $(pwd)/dfsan-plugin.so -Xclang -add-plugin -Xclang ToyClangPlugin test.cpp -o /tmp/test
{
python3 -m tclib download \
https://curl.haxx.se/download/curl-7.69.1.tar.gz /tmp/curl-7.69.1.tar.gz 01ae0c123dee45b01bbaef94c0bc00ed2aec89cb2ee0fd598e0d302a6b5e0a98
#https://curl.haxx.se/download/curl-7.41.0.tar.gz /tmp/curl-7.41.0.tar.gz
#https://ftp.gnu.org/gnu/wget/wget-1.19.5.tar.gz  /tmp/wget-1.19.5.tar.gz b39212abe1a73f2b28f4c6cb223c738559caac91d6e416a6d91d4b9d55c9faee
#https://ftp.gnu.org/gnu/sed/sed-4.2.2.tar.gz /tmp/sed-4.2.2.tar.gz fea0a94d4b605894f3e2d5572e3f96e4413bcad3a085aae7367c2cf07908b2ff
#https://sourceforge.net/projects/optipng/files/OptiPNG/optipng-0.5.3/optipng-0.5.3.tar.gz/download  /tmp/optipng-0.5.3.tar.gz fa910c7dc8dbe29323494097255f034d374f8ef0e42ace3e3855408e014319e5
echo >/tmp/plog.log
echo >/tmp/loc_vars.txt

APP=curl-7.69.1
rm -rf /tmp/$APP
export DFSAN_OPTIONS=warn_unimplemented=0
INCLUDE=$(pwd)/../include
export CC="clang-11 -I$INCLUDE -fsanitize=dataflow -fsanitize-blacklist=/tmp/openssl-list.txt\
 -Xclang -load -Xclang /home/ubuntu/plwork/PL-working/dfsan-plugin/dfsan-plugin.so -Xclang -add-plugin -Xclang DfsanPlugin"
p ushd /tmp
tar -xzf $APP.tar.gz
cd $APP
export DFPG_MODE=genSource
./configure # --with-ssl=openssl
echo ''> /tmp/patch.txt;make clean;make
#sed -ri  '/connect.c/d' /tmp/loc_vars.txt
export DFPG_MODE=genSink
make clean;make
popd
python3 ../dfsan-inject/applyPatch.py /tmp/$APP
pushd /tmp/$APP
unset DFPG_MODE
make
popd

}
python3 -m tclib ifttt 'done'
