python3 -m tclib download http://corpus.canterbury.ac.nz/resources/cantrbry.zip  ../cantrbry.zip c44b686dfc137e74aba4db0540e5d6568cb09e270ba8f8411d2f9df24f39a1a6
mkdir tests
pushd tests
unp ../../cantrbry.zip
alias gzip=../gzip
echo "1 2 3"> a.in
echo "1 2 3 4 5"> b.in
for x in *;do
gzip $x ||true
done
for x in *;do
gzip -d $x ||true
done

rm -f *
unp ../../cantrbry.zip

for x in *;do
gzip -v --best $x ||true
done

for x in *;do
gzip -l $x ||true
done