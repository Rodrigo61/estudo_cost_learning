
#LOCAL
#UCI_PATH="/home/rodrigo/Desktop/datasets_UCI/"

#RECOD
#UCI_PATH="/home/rodrigoaf/estudo_cost_learning/UCI/"

# JACQUES
UCI_PATH='/datasets/wainer/imbalance/UCI/'

SUMMARY_LIST_FILENAME="summary_list"

find $UCI_PATH -name "*_summary*" > $SUMMARY_LIST_FILENAME

echo "Lista gerada e salva em $SUMMARY_LIST_FILENAME"
