source env.sh
set -e
cd /$TMP
python3 -m tclib download https://ftp.gnu.org/gnu/wget/wget-1.19.5.tar.gz  wget-1.19.5.tar.gz
#python3 -m tclib download https://ftp.gnu.org/gnu/wget/wget-1.15.tar.gz  wget-1.15.tar.gz 52126be8cf1bddd7536886e74c053ad7d0ed2aa89b4b630f76785bac21695fcd
VER=1.19.5
rm -rf wget-$VER
tar -xzf wget-$VER.tar.gz
pushd /$TMP/wget-$VER
./configure --with-ssl=openssl
make -j8
cd src
./wget --version
popd
