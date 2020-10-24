shopt -s expand_aliases #enable aliases
set -e
clear
make -j4
export AHOME=$(pwd)
INCLUDE=$(pwd)/../include
WWS=$2
export WORKDIR=/tmp/$WWS
APP=$1
mkdir -p $WORKDIR
python3 $AHOME/../dfsan-inject/genInjectTask.py $APP $WORKDIR 1 0
#                                                               batch total,id
cd $WORKDIR
ARCHIEVE=$APP.tar.gz
#cp /home/ubuntu/plwork/PL-working/dfsan-inject/task.txt $WORKDIR
{
down="python3 -m tclib download"
configure='./configure'
case $APP in
	curl-7.69.3) ARCHIEVE=curl-7.69.3.tar.xz
		$down https://curl.haxx.se/download/curl-7.69.3.tar.xz $ARCHIEVE any;;
	fribidi-1.0.7) ARCHIEVE=fribidi-1.0.7.tar.bz2
		$down https://github.com/fribidi/fribidi/releases/download/v1.0.7/fribidi-1.0.7.tar.bz2 $ARCHIEVE 5ab5f21e9f2fc57b4b40f8ea8f14dba78a5cc46d9cf94bc5e00a58e6886a935d;;
	patch-2.7.1) echo 'parse-datetime.y'>$WORKDIR/blacklist.txt
		ARCHIEVE=$APP.tar.xz; $down https://ftp.gnu.org/gnu/patch/patch-2.7.1.tar.xz $ARCHIEVE any;;
	kilo-0.0.1) ARCHIEVE=kilo-0.0.1.zip;configure=''
		$down https://github.com/antirez/kilo/archive/d65f4c92e8ed405937a7bac3248d24fa6b40eb6f.zip $ARCHIEVE any;;
	cflow-1.5) ARCHIEVE=cflow-1.5.tar.bz2
		$down https://ftp.gnu.org/gnu/cflow/cflow-1.5.tar.bz2 cflow-1.5.tar.bz2 any
		echo 'c.l'>$WORKDIR/blacklist.txt;;
	cflow-1.6) ARCHIEVE=cflow-1.6.tar.bz2
		$down https://ftp.gnu.org/gnu/cflow/cflow-1.6.tar.bz2 cflow-1.6.tar.bz2 any
		echo 'c.l'>$WORKDIR/blacklist.txt;;
	gzip-1.2.4a) $down https://ftp.gnu.org/gnu/gzip/gzip-1.2.4a.tar.gz $ARCHIEVE any 
		echo 'unlzw.c'>$WORKDIR/blacklist.txt;;
	zsh-5.4.2) ARCHIEVE=zsh-5.4.2.tar.xz
		$down https://sourceforge.net/projects/zsh/files/zsh/5.4.2/zsh-5.4.2.tar.xz/download $ARCHIEVE a80b187b6b770f092ea1f53e89021d06c03d8bbe6a5e996bcca3267de14c5e52 ;; 
	gnuplot-5.2.5) $down https://sourceforge.net/projects/gnuplot/files/gnuplot/5.2.5/gnuplot-5.2.5.tar.gz/download $ARCHIEVE 039db2cce62ddcfd31a6696fe576f4224b3bc3f919e66191dfe2cdb058475caa ;;
	libtasn1-4.3) $down https://ftp.gnu.org/gnu/libtasn1/libtasn1-4.3.tar.gz $ARCHIEVE any 
		MAKEARGS=' -i V=1';configure='./configure'
		echo 'ASN1.c'>$WORKDIR/blacklist.txt;;
	gnuplot-5.2.5) $down https://sourceforge.net/projects/gnuplot/files/gnuplot/5.2.5/gnuplot-5.2.5.tar.gz/download $ARCHIEVE 039db2cce62ddcfd31a6696fe576f4224b3bc3f919e66191dfe2cdb058475caa ;;
	bc-1.06) $down https://ftp.gnu.org/gnu/bc/bc-1.06.tar.gz $ARCHIEVE any 
		echo 'scan.c'>$WORKDIR/blacklist.txt;; #like a preprocessed file
	vim-8.0)
		;;
	nginx-*) configure='./configure --without-http_rewrite_module --without-http_gzip_module'
		$down https://nginx.org/download/$APP.tar.gz $ARCHIEVE any ;;
 	redis-*) $down https://download.redis.io/releases/$APP.tar.gz $ARCHIEVE any ;;
	screen-3.9.15) $down https://ftp.gnu.org/gnu/screen/screen-3.9.15.tar.gz $ARCHIEVE any ;;
	optipng-0.5.3) $down https://github.com/TianyiChen/PL-assets/releases/download/main/optipng-0.5.3.tar.gz $ARCHIEVE 69df63fd29fa499c85687fa35569fd208741a91b4f34949d1fd8463ebd353384
		make(){
			pushd src
			command make -i -f scripts/unix.mak "$@"
			popd
		}
		configure='' ;;
	urjtag-0.8) $down https://master.dl.sourceforge.net/project/urjtag/urjtag/0.8/urjtag-0.8.tar.gz $ARCHIEVE 47684f0552fe90aae1d1afbc4264433ec467edab1b7e6b37145bf783d956345b 
		echo 'svf_flex.c'>$WORKDIR/blacklist.txt;;
	latex2rtf-2.1.1) $down https://master.dl.sourceforge.net/project/latex2rtf/latex2rtf-unix/2.1.1/latex2rtf-2.1.1beta8.tar.gz $ARCHIEVE 6e0c9da83af5e13ab732227792367f25ffcedbfab22b74911a269e2470383554
		APP=latex2rtf configure='';;
	shntool-3.0.5) $down http://shnutils.freeshell.org/shntool/dist/src/shntool-3.0.5.tar.gz $ARCHIEVE c496d7c6079609d0b71cca5f1ff7202962bb7921c3fe0e6081ae5a143ce3b14b ;;
	sed-4.3) $down https://ftp.gnu.org/gnu/sed/sed-4.3.tar.xz sed-4.3.tar.xz any
		DFSAN_HEADPARA=' --rtlib=compiler-rt'
		ARCHIEVE=sed-4.3.tar.xz ;;
	grep-2.19) ARCHIEVE=grep-2.19.tar.xz
		$down https://ftp.gnu.org/gnu/grep/grep-2.19.tar.xz $ARCHIEVE any ;;
	sort-7.2) $down https://ftp.gnu.org/gnu/coreutils/coreutils-7.2.tar.gz coreutils-7.2.tar.gz any 
		MAKEARGS="-i" # other binaries fail
		APP=coreutils-7.2;ARCHIEVE=$APP.tar.gz	;;
	readelf-2.24) $down https://ftp.gnu.org/gnu/binutils/binutils-2.24.tar.gz binutils-2.24.tar.gz any
		MAKEARGS="-i"
		APP=binutils-2.24;ARCHIEVE=$APP.tar.gz ;;
	readelf-2.32) $down https://ftp.gnu.org/gnu/binutils/binutils-2.32.tar.gz binutils-2.32.tar.gz any
		MAKEARGS="-i"
		APP=binutils-2.32;ARCHIEVE=$APP.tar.gz ;;
	tar-*) MAKEARGS='V=1'
	$down https://ftp.gnu.org/gnu/tar/$APP.tar.gz $APP.tar.gz any 
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
	*) echo "Unknown app" && exit 1 ;;
esac

rm -rf $WORKDIR/$APP ||sudo rm -rf $WORKDIR/$APP
export DFSAN_OPTIONS="warn_unimplemented=0" #":coverage=1:coverage_dir=/tmp/cov"
#export DFSAN_HEADPARA=' -fsanitize=dataflow -fsanitize-blacklist=/tmp/openssl-list.txt'
export CC="clang-dfsan"
export CXX="clang-dfsan"

pushd $WORKDIR
> plog.log
> loc_vars.txt
> visited_edges.txt
cat > libdfsanlabels.c <<- EOM
#include <sanitizer/dfsan_interface.h>
dfsan_label _SaN_bad00000;
void __attribute__ ((constructor)) _dfsan_init_bad00000(){
_SaN_bad00000=dfsan_create_label("_SaN_bad00000",0);
}
EOM
clang-11 -shared -fPIC libdfsanlabels.c -o libdfsanlabels.a
unp $ARCHIEVE >/dev/null
}
