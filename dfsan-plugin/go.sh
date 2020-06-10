set -e
clear
make
export PATH=$(pwd):$PATH
AHOME=$(pwd)
INCLUDE=$(pwd)/../include
WWS=$2
export WORKDIR=/tmp/$WWS
APP=$1
mkdir -p $WORKDIR
python3 $AHOME/../dfsan-inject/genInjectTask.py $APP $WORKDIR $3 $4
#                                                               batch total,id
cd $WORKDIR
#cp /home/ubuntu/plwork/PL-working/dfsan-inject/task.txt $WORKDIR
{
down="python3 -m tclib download"
configure='./configure -q'
case $APP in
	tar-*) $down https://ftp.gnu.org/gnu/tar/$APP.tar.gz $APP.tar.gz any 
		echo 'safe-read.c'>$WORKDIR/blacklist.txt;;
	wget-1.12) configure='./configure --without-ssl'
		echo 'css_.c' >$WORKDIR/blacklist.txt
		$down https://ftp.gnu.org/gnu/wget/$APP.tar.gz  $APP.tar.gz any ;;
	wget-1.19.5) configure='./configure  --with-ssl=openssl'
		echo 'css_.c' >$WORKDIR/blacklist.txt
		$down https://ftp.gnu.org/gnu/wget/wget-1.19.5.tar.gz  wget-1.19.5.tar.gz any ;;#b39212abe1a73f2b28f4c6cb223c738559caac91d6e416a6d91d4b9d55c9faee ;;
	wget-*) configure='./configure  --with-ssl=openssl'
		echo 'css_.c' >$WORKDIR/blacklist.txt
	$down https://ftp.gnu.org/gnu/wget/$APP.tar.gz  $APP.tar.gz any ;;
	sed-*) $down https://ftp.gnu.org/gnu/sed/$APP.tar.gz $APP.tar.gz any ;;
	*) echo "Unknown app" && exit 1 ;;
esac
#https://ftp.gnu.org/gnu/tar/tar-1.30.tar.gz tar-1.30.tar.gz any
#https://sourceforge.net/projects/optipng/files/OptiPNG/optipng-0.5.3/optipng-0.5.3.tar.gz/download optipng-0.5.3.tar.gz fa910c7dc8dbe29323494097255f034d374f8ef0e42ace3e3855408e014319e5
#https://curl.haxx.se/download/curl-7.69.1.tar.gz curl-7.69.1.tar.gz 01ae0c123dee45b01bbaef94c0bc00ed2aec89cb2ee0fd598e0d302a6b5e0a98
#https://curl.haxx.se/download/curl-7.41.0.tar.gz curl-7.41.0.tar.gz
#https://ftp.gnu.org/gnu/wget/wget-1.11.4.tar.gz wget-1.11.4.tar.gz 7315963b6eefb7530b4a4f63a5d5ccdab30078784cf41ccb5297873f9adea2f3
#https://ftp.gnu.org/gnu/sed/sed-4.2.2.tar.gz sed-4.2.2.tar.gz fea0a94d4b605894f3e2d5572e3f96e4413bcad3a085aae7367c2cf07908b2ff
> $WORKDIR/plog.log
> $WORKDIR/loc_vars.txt
rm -rf $WORKDIR/$APP
export DFSAN_OPTIONS=warn_unimplemented=0
export CC="clang-dfsan -L$WORKDIR -ldfsanlabels -L$AHOME -ldfsan-rt -w -g -I$INCLUDE -fsanitize=dataflow -fsanitize-blacklist=/tmp/openssl-list.txt\
 -Xclang -load -Xclang $AHOME/dfsan-plugin.so -Xclang -add-plugin -Xclang DfsanPlugin"
pushd $WORKDIR
> libdfsanlabels.c
clang-dfsan -shared libdfsanlabels.c -o libdfsanlabels.a
tar -xzf $APP.tar.gz
cd $APP
export DFPG_MODE=genSource
$configure
> $WORKDIR/visited.txt;make clean;make
python3 $AHOME/replace.py
echo '_____________genSink_______________'>>$WORKDIR/plog.log
export DFPG_MODE=genSink
make clean;make
python3 $AHOME/replace.py
popd
clang-dfsan -shared -fPIC libdfsanlabels.c -o libdfsanlabels.a
#python3 $AHOME/../dfsan-inject/applyPatch.py $WORKDIR/$APP
pushd $WORKDIR/$APP
unset DFPG_MODE
make clean
make -j4
cd $WORKDIR/$APP/
>$WORKDIR/san.log
>$WORKDIR/sansrc.log
>$WORKDIR/visited_edges.txt
#src/wget www.google.com 2>/dev/null
#src/wget ftp://ftp.gnu.org/gnu/wget/ 2>/dev/null
. $AHOME/../benchmark/test-$APP.sh
popd
python3 $AHOME/san2fileline.py $WORKDIR
}
python3 -m tclib ifttt done$4/$3
