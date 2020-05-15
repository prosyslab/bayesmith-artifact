if [ $# -eq 0 ]
	then
		echo 'Instance name needed'
		exit
fi
make
python3 genInjectTask.py $1
cp task.txt /tmp
./dfsan-inject < task.txt ../../bingo-ci-experiment/benchmark/$1/$1.c --
pushd ../benchmark
#$1.sh
popd
python3 applyPatch.py
exit

clang-9 -static -fsanitize=dataflow -w wget-1.11.4.out.c -o task -fsanitize-blacklist=openssl-list.txt -L/home/ubuntu/Desktop/lib/openssl-1.1.1e/ -lssl -lcrypto

clang-9 -static -w wget-1.19.5.c -o task  -L~/Desktop/wget-1.19.5/lib/ ~/Desktop/wget-1.19.5/lib/*.o -lssl -lcrypto -ldl -pthread -lgnutls

export CC="clang -fPIC -fsanitize=dataflow -fsanitize-blacklist=/tmp/openssl-list.txt"

#dfsan
export CFLAGS=' -fPIC -g -fsanitize=dataflow -fsanitize-blacklist=/tmp/openssl-list.txt  '

export CC="clang-11"

./configure --with-ssl=openssl
pushd src
ASAN_OPTIONS=coverage=1 ./wget https:// www.google.com
/usr/lib/llvm-9/bin/sancov -symbolize 
