#!/bin/bash

## vetor de metricas
declare -a measures=("acc" "f1" "gmeans" "mcc")

## vetor de algoritmos
declare -a learners=("svm" "rf")

R_PATH_STR=""

## recriando run_all.sh 
run_all_path="run_all.sh"
echo "#!/bin/bash" > $run_all_path


## criando combinacoes
for measure in "${measures[@]}"
do
	for learner in "${learners[@]}"
	do
		#gerando arquivo com aprendizado normal (.SH)
		normal_file="${measure}_${learner}_false.sh"
		content_normal="Rscript --vanilla tuning.R $@ $measure $learner false"
		echo "#!/bin/bash
export PATH=/home/rodrigoaf/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
$content_normal" > $normal_file
		chmod 755 $normal_file
		
		#gerando arquivo com aprendizado normal (.sub)
		normal_file_sub="${measure}_${learner}_false.sub"
		echo 'N=196
universe                = vanilla
executable            = '$normal_file'
arguments               = $(Process)
Requirements = ((Machine == "cerebro.recod") || (Machine == "deepthought.recod") || (Machine == "eddie.recod") || (Machine == "magi.recod") || (Machine == "sms02.recod") || (Machine == "theengine.recod") || (Machine == "twin01-b.recod") || (Machine == "twin01-d.recod") || (Machine == "twin02-c.recod") || (Machine == "x01.recod") || (Machine == "x02.recod") || (Machine == "x03.recod") ) 
output                = condor.out.$(CLUSTER).$(Process)
log                     = condor.log.$(CLUSTER).($Process)
error                   = condor.err.$(CLUSTER).$(Process)

queue $(N) ' > $normal_file_sub
		echo "condor_submit $normal_file_sub" >> $run_all_path # append no run_all.sh


		#gerando arquivo com aprendizado weight space
		ws_file="${measure}_${learner}_true.sh"
		content_ws="Rscript --vanilla tuning.R $@ $measure $learner true"
		echo "#!/bin/bash
export PATH=/home/rodrigoaf/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin.sh
$content_ws" > $ws_file
		chmod 755 $ws_file
		
		#gerando arquivo com aprendizado weight space (.sub)
		ws_file_sub="${measure}_${learner}_false.sub"
		echo 'N=196
universe                = vanilla
executable            = '$ws_file'
arguments               = $(Process)
Requirements = ((Machine == "cerebro.recod") || (Machine == "deepthought.recod") || (Machine == "eddie.recod") || (Machine == "magi.recod") || (Machine == "sms02.recod") || (Machine == "theengine.recod") || (Machine == "twin01-b.recod") || (Machine == "twin01-d.recod") || (Machine == "twin02-c.recod") || (Machine == "x01.recod") || (Machine == "x02.recod") || (Machine == "x03.recod") ) 
output                = condor.out.$(CLUSTER).$(Process)
log                     = condor.log.$(CLUSTER).($Process)
error                   = condor.err.$(CLUSTER).$(Process)

queue $(N) ' > $ws_file_sub
		echo "condor_submit $ws_file_sub" >> $run_all_path # append no run_all.sh
	done
done
