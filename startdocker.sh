. init.sh
docker run -it \
--mount type=bind,source=/tmp,target=/tmp \
--mount type=bind,source=$PWD,target=/home/ubuntu/dynamicbingo,readonly \
--mount type=bind,source=$PWD/../bingo-ci-experiment,target=/home/ubuntu/bingo-ci-experiment \
--mount type=bind,source=$LLVM_ROOT,target=/tmp/llvm-project,readonly \
-w /home/ubuntu/dynamicbingo \
dynamicbingo:latest
