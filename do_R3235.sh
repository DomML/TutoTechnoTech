lyon=$(ssh -t lyon 'oarstat -u dmias | grep dmias | sed "s/  */ /g" | cut -d" " -f2 | tr "\n" " "');
lille=$(ssh -t lille 'oarstat -u dmias | grep dmias | sed "s/  */ /g" | cut -d" " -f2 | tr "\n" " "'); 
echo $lyon $lille; 
g="$lyon $lille"; 
echo $g;

r=$(oarstat -f -u dmias | grep "command" | sort | cut -d"/" -f7);
cd ~/capsid/2022_01_07_MD_HtH/HtH.R32R35A_1per.DNA/;
for i in {001..030}; do 
	if [ $(echo "$r" | grep $i | wc -l) -ne 0 ]; then 
		echo "$i running here"; continue; fi; 
	if [ $(echo "$g" | grep $i | wc -l) -ne 0 ]; then 
		echo "$i running elsewhere"; continue; fi;

	if grep -q "WRITING VELOCITIES TO OUTPUT FILE AT STEP 10000000" R32*_"$i".out ; then 
		echo "$i finished"; continue; fi; 

	echo $i; 
	oarsub -p "cluster in ('grouille', 'gruss')" -n $i -l gpu=1,walltime=168 -t exotic -t besteffort -t idempotent --checkpoint 60  ~/capsid/2022_01_07_MD_HtH/HtH.R32R35A_1per.DNA/MD_"$i".be.sh
done
