#!/bin/bash

## vetor de metricas
declare -a measures=("acc" "f1" "gmeans" "mcc" "auc")

## vetor de algoritmos
declare -a learners=("svm" "rf" "xgboost")

## criando caso nao exista o diretório submission_files
submission_files_dir="submission_files"
mkdir -p $submission_files_dir
echo "pasta 'submission_files' criado no diretorio $HOME_PATH"


## recriando run_all.sh 
run_all_path="run_all.sh"
echo "#!/bin/bash" > $run_all_path
echo "cd $submission_files_dir" >> $run_all_path
chmod 755 $run_all_path


# Agora vamos trabalhar dentro do diretorio de arquivos de submissao
cd $submission_files_dir


## criando combinacoes
for measure in "${measures[@]}"
do
	for learner in "${learners[@]}"
	do
		#gerando arquivo com aprendizado normal (.SH)
		normal_file="${measure}_${learner}_false.sh"
		content_normal='Rscript --vanilla ../tuning.R --dataset_id=$@ --measure='$measure' --model='$learner''
		echo "#!/bin/bash 
export PATH=/home/rodrigoaf/R-3.3.3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
$content_normal" > $normal_file
		chmod 755 $normal_file
		
		#gerando arquivo com aprendizado normal(false) (.sub)
		normal_file_sub="${measure}_${learner}_false.sub"
#INSERT_REQUIREMENTS_CONTENT é preenchido antes da submissao para sempre mante-lo atualizado
		echo 'N=196
universe                = vanilla
executable            = '$normal_file'
arguments               = $(Process)
output                = condor.out.$(CLUSTER).$(Process)
log                     = condor.log.$(CLUSTER).($Process)
error                   = condor.err.$(CLUSTER).$(Process)

queue $(N) ' > $normal_file_sub
		echo "sleep 20 | condor_submit $normal_file_sub" >> ../$run_all_path # append no run_all.sh




		#gerando arquivo com aprendizado weight space
		ws_file="${measure}_${learner}_true.sh"
		content_ws='Rscript --vanilla ../tuning.R --dataset_id=$@ --measure='$measure' --model='$learner' --weight_space'
		echo "#!/bin/bash 
export PATH=/home/rodrigoaf/R-3.3.3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
$content_ws" > $ws_file
		chmod 755 $ws_file
		#gerando arquivo com aprendizado weight space(true) (.sub)
		ws_file_sub="${measure}_${learner}_true.sub"
		echo 'N=196
universe                = vanilla
executable            = '$ws_file'
arguments               = $(Process) 
output                = condor.out.$(CLUSTER).$(Process)
log                     = condor.log.$(CLUSTER).($Process)
error                   = condor.err.$(CLUSTER).$(Process)

queue $(N) ' > $ws_file_sub
		echo "sleep 20 | condor_submit $ws_file_sub" >> ../$run_all_path # append no run_all.sh
	done
done


echo "Arquivos de submissão e script foram criados"

