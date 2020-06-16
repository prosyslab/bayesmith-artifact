set -e
clear
make
AHOME=$(pwd)
INCLUDE=$(pwd)/../include
MAKEARGS="-i"
WWS=$2
export WORKDIR=/tmp/$WWS
APP=$1
mkdir -p $WORKDIR
python3 $AHOME/../dfsan-inject/genInjectTask.py $APP $WORKDIR $3 $4
#                                                               batch total,id
cd $WORKDIR
ARCHIEVE=$APP.tar.gz
#cp /home/ubuntu/plwork/PL-working/dfsan-inject/task.txt $WORKDIR
{
down="python3 -m tclib download"
configure='./configure'
case $APP in
	latex2rtf-2.1.1) $down https://master.dl.sourceforge.net/project/latex2rtf/latex2rtf-unix/2.1.1/latex2rtf-2.1.1beta8.tar.gz $ARCHIEVE 6e0c9da83af5e13ab732227792367f25ffcedbfab22b74911a269e2470383554
		APP=latex2rtf ;;
	shntool-3.0.5) $down http://shnutils.freeshell.org/shntool/dist/src/shntool-3.0.5.tar.gz $ARCHIEVE c496d7c6079609d0b71cca5f1ff7202962bb7921c3fe0e6081ae5a143ce3b14b ;;
	sed-4.3) $down https://ftp.gnu.org/gnu/sed/sed-4.3.tar.xz sed-4.3.tar.xz any
		ARCHIEVE=sed-4.3.tar.xz ;;
	grep-2.19) ARCHIEVE=grep-2.19.tar.xz
		$down https://ftp.gnu.org/gnu/grep/grep-2.19.tar.xz $ARCHIEVE any ;;
	sort-7.2) $down https://ftp.gnu.org/gnu/coreutils/coreutils-7.2.tar.gz coreutils-7.2.tar.gz any 
		APP=coreutils-7.2;ARCHIEVE=$APP.tar.gz	;;
	readelf-2.24) $down https://ftp.gnu.org/gnu/binutils/binutils-2.24.tar.gz binutils-2.24.tar.gz any
		APP=binutils-2.24;ARCHIEVE=$APP.tar.gz ;;
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
> $WORKDIR/visited_edges.txt
rm -rf $WORKDIR/$APP ||sudo rm -rf $WORKDIR/$APP
export DFSAN_OPTIONS=warn_unimplemented=0
export CC="clang-dfsan"
pushd $WORKDIR
> libdfsanlabels.c
clang-11 -shared -fPIC libdfsanlabels.c -o libdfsanlabels.a
unp $ARCHIEVE
cd $APP
export DFPG_MODE=genSource
$configure
export DFSAN_HEADPARA=" -L$WORKDIR -ldfsanlabels -L$AHOME -ldfsan-rt -w -g -I$INCLUDE -fsanitize=dataflow -fsanitize-blacklist=/tmp/openssl-list.txt\
 -Xclang -load -Xclang $AHOME/dfsan-plugin.so -Xclang -add-plugin -Xclang DfsanPlugin"
> $WORKDIR/visited.txt;make clean;make $MAKEARGS
python3 $AHOME/replace.py
echo '_____________genSink_______________'>>$WORKDIR/plog.log
export DFPG_MODE=genSink
make clean;make $MAKEARGS
python3 $AHOME/replace.py
popd
clang-11 -shared -fPIC libdfsanlabels.c -o libdfsanlabels.a
#python3 $AHOME/../dfsan-inject/applyPatch.py $WORKDIR/$APP
pushd $WORKDIR/$APP
unset DFPG_MODE
make clean
make $MAKEARGS
cd $WORKDIR/$APP/
>$WORKDIR/san.log
>$WORKDIR/sansrc.log
#src/wget www.google.com 2>/dev/null
#src/wget ftp://ftp.gnu.org/gnu/wget/ 2>/dev/null
. $AHOME/../benchmark/test-$APP.sh
popd
python3 $AHOME/san2fileline.py $WORKDIR
}
python3 -m tclib ifttt done$4/$3
