#!/bin/bash
export PATH=/home/rodrigoaf/R-3.2.5/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
Rscript --vanilla ../tuning.R --dataset_id=0 --measure=mcc --model=xgboost --weight_space
