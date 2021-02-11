pushd Test
for file in array.b arrayp.b aryprm.b atan.b  checklib.b div.b exp.b fact.b jn.b ln.b mul.b raise.b signum sine.b sqrt1.b sqrt2.b sqrt.b testfn.b 
do
../bc/bc -l $file
done
popd
