system("if [ -L contributions/bjContributions ] ; then 
echo 'it is here' ; 
rm contributions/bjContributions ;else echo 'it is not here'; 
ln -s ../bjContributions contributions/bjContributions
       fi")

# dummy directory
system("if [ -L contributions/Dummy ] ; then 
echo 'it is here' ; 
rm contributions/Dummy ; else echo 'it is not here'; 
ln -s ../Dummy contributions/Dummy
fi")
