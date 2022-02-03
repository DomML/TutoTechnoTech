#!/bin/bash
# exemple de oarsub BE
# un seul noeud: oarsub -p "cluster='grouille'" -l gpu=1,walltime=4 -t exotic -t besteffort -t idempotent --checkpoint 60 $HOME/test_namd3/namd.sh
# pour gemini: 
# - oarsub -p "cluster='gemini'" -l gpu=4,walltime=4 -t exotic -t besteffort -t idempotent --checkpoint 60 $HOME/test_namd3/namd.sh
# - ./namd3 +idlepoll +p 4 +setcpuaffinity spikeSA_ACE2_trimer_boundOK_equil.conf +devices 0,1,2,3 

. /etc/profile.d/lmod.sh
module load namd3-cuda

job=R3235A_001

out="${job}.out"

echo OAR_NODEFILE $OAR_NODEFILE >> $out
namd3 +idlepoll +p1 +setcpuaffinity +devices 0 MD_001.conf >> $out &
namd3pid=$!

handler() { 
  echo "Caught checkpoint signal at: `date`"
  kill -TERM $namd3pid
  exit 99
}

trap handler SIGUSR2

wait $namd3pid

exit_code=$?

date
echo "Namd terminated with exit code ${exit_code}"

if [ $exit_code -ne 0 ]; then
  exit 99
fi

exit $exit_code