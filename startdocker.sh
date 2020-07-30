docker run -it \
--mount type=bind,source=/tmp,target=/tmp \
--mount type=bind,source=$PWD,target=/home/ubuntu/dynamicbingo,readonly \
--mount type=bind,source=$PWD/../bingo-ci-experiment,target=/home/ubuntu/bingo-ci-experiment,readonly \
--mount type=bind,source=/home/ubuntu/Desktop/llvm,target=/tmp/llvm-project,readonly \
-w /home/ubuntu/dynamicbingo \
dynamicbingo:latest
