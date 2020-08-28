python3 -m tclib download http://corpus.canterbury.ac.nz/resources/cantrbry.zip  ../cantrbry.zip e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
mkdir tests
pushd tests
unp ../../cantrbry.zip
alias gzip=../gzip
echo "1 2 3"> a.in
echo "1 2 3 4 5"> a.in
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