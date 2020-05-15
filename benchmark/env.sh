export DFSAN_OPTIONS=warn_unimplemented=0
#CC=clang-11
CC="clang-11 -g -fsanitize=dataflow -fsanitize-blacklist=/tmp/openssl-list.txt"
CLANG_TIDY=clang-tidy-11
TMP=/dev/shm
PWD=$(pwd)
SMAKE=$(pwd)/smake
