set -e
clear
make
AHOME=$(pwd)
INCLUDE=$(pwd)/../include
WWS=$2
export WORKDIR=/tmp/$WWS
APP=$1
mkdir -p $WORKDIR
python3 $AHOME/../dfsan-inject/genInjectTask.py $APP $WORKDIR
cd $WORKDIR
#cp /home/ubuntu/plwork/PL-working/dfsan-inject/task.txt $WORKDIR
#time clang-11  -fsanitize=dataflow  -Xclang -load -Xclang $(pwd)/dfsan-plugin.so -Xclang -add-plugin -Xclang ToyClangPlugin test.cpp -o $WORKDIR/test
{
down="python3 -m tclib download"
case $APP in
	tar-*) $down https://ftp.gnu.org/gnu/tar/$APP.tar.gz $APP.tar.gz any ;;
	wget-1.19.5) $down https://ftp.gnu.org/gnu/wget/wget-1.19.5.tar.gz  wget-1.19.5.tar.gz b39212abe1a73f2b28f4c6cb223c738559caac91d6e416a6d91d4b9d55c9faee ;;
	*) echo "Unknown app" && exit 1 ;;
esac
#https://ftp.gnu.org/gnu/tar/tar-1.30.tar.gz tar-1.30.tar.gz any
#https://sourceforge.net/projects/optipng/files/OptiPNG/optipng-0.5.3/optipng-0.5.3.tar.gz/download optipng-0.5.3.tar.gz fa910c7dc8dbe29323494097255f034d374f8ef0e42ace3e3855408e014319e5
#https://curl.haxx.se/download/curl-7.69.1.tar.gz curl-7.69.1.tar.gz 01ae0c123dee45b01bbaef94c0bc00ed2aec89cb2ee0fd598e0d302a6b5e0a98
#https://curl.haxx.se/download/curl-7.41.0.tar.gz curl-7.41.0.tar.gz
#https://ftp.gnu.org/gnu/wget/wget-1.11.4.tar.gz wget-1.11.4.tar.gz 7315963b6eefb7530b4a4f63a5d5ccdab30078784cf41ccb5297873f9adea2f3
#https://ftp.gnu.org/gnu/sed/sed-4.2.2.tar.gz sed-4.2.2.tar.gz fea0a94d4b605894f3e2d5572e3f96e4413bcad3a085aae7367c2cf07908b2ff
echo >$WORKDIR/plog.log
echo >$WORKDIR/loc_vars.txt

rm -rf $WORKDIR/$APP
export DFSAN_OPTIONS=warn_unimplemented=0
export CC="clang-11 -I$INCLUDE -fsanitize=dataflow -fsanitize-blacklist=/tmp/openssl-list.txt\
 -Xclang -load -Xclang /home/ubuntu/plwork/PL-working/dfsan-plugin/dfsan-plugin.so -Xclang -add-plugin -Xclang DfsanPlugin"
pushd $WORKDIR
tar -xzf $APP.tar.gz
cd $APP
export DFPG_MODE=genSource
./configure  --with-ssl=openssl
echo ''> $WORKDIR/patch.txt;make clean;make
echo '_____________genSink_______________'>>$WORKDIR/plog.log
export DFPG_MODE=genSink
make clean;make
popd
python3 $AHOME/../dfsan-inject/applyPatch.py $WORKDIR/$APP
pushd $WORKDIR/$APP
unset DFPG_MODE
if ! make 2>makeerr.txt;then
	crc=$(crc32 makeerr.txt)
	retry=1
	while ((retry<=10)) && ! make 2>makeerr.txt
	do
		python3 $AHOME/autofix.py
		((++retry))
	done
fi
popd

}
python3 -m tclib ifttt 'done'
