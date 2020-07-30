python3 -m tclib download https://www.ee.columbia.edu/~dpwe/sounds/music/africa-toto.wav ../example.wav b08c967031c9db3a832eb12a34515bd5cb24ca56bad1988019c7cfc07d6a4d71
cd src
{
set +e
./shntool len ../../example.wav
./shntool fix ../../example.wav
./shntool hash ../../example.wav
./shntool pad ../../example.wav
./shntool split  -l 1000000 ../../example.wav
./shntool cmp split-track03.wav split-track04.wav
./shntool cmp split-track07.wav split-track08.wav
set -e
}
