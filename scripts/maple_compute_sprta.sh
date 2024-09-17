#!bin/bash

###### handle arguments ######

ALN_DIR=$1 # aln dir
TREE_DIR=$2 # tree dir
MAPLE_PATH=$3 # path to CMAPLE executable
CMAPLE_SPRTA_TREE_PREFIX=$4 # The prefix of trees with SPRTA computed by CMAPLE
MAPLE_SPRTA_TREE_PREFIX=$5 # The prefix of trees with SPRTA computed by MAPLE
MODEL=$6 # Substitution model
BLENGTHS_FIXED=$7 # keep blengths fixed or not
PYPY_PATH=$8 # path to pypy
PRINT_LESS_INFO_SEQS=$9 # print SPRTA for less-informative sequences

BL_FIXED_OPT=""
if [ "${BLENGTHS_FIXED}" = true ]; then
  BL_FIXED_OPT=" --blfix"
fi

PRINT_LESS_INFO_SEQS_OPT=""
if [ "${PRINT_LESS_INFO_SEQS}" = true ]; then
  PRINT_LESS_INFO_SEQS_OPT=" --supportForIdenticalSequences"
fi

MAPLE_PARAMS="--SPRTA --overwrite --networkOutput --keepInputIQtreeSupports --doNotImproveTopology --doNotReroot" # MAPLE params


### pre steps #####



############
mkdir -p ${TREE_DIR}
# remove old results
rm -f ${TREE_DIR}/${MAPLE_SPRTA_TREE_PREFIX}${aln}_nexusTree.tree

for aln_path in "${ALN_DIR}"/*.maple; do
	aln=$(basename "$aln_path")
    echo "Compute SPRTA (by MAPLE) for the tree ${ML_TREE_PREFIX}${aln}.treefile inferred from ${aln}"
    echo "cd ${ALN_DIR} && ${PYPY_PATH} ${MAPLE_PATH} --input ${aln} --output ${ALN_DIR}/${MAPLE_SPRTA_TREE_PREFIX}${aln} --inputTree ${TREE_DIR}/${CMAPLE_SPRTA_TREE_PREFIX}${aln}.treefile --model ${MODEL} ${MAPLE_PARAMS} ${BL_FIXED_OPT} ${PRINT_LESS_INFO_SEQS_OPT}"
    cd ${ALN_DIR} && ${PYPY_PATH} ${MAPLE_PATH} --input ${aln} --output ${ALN_DIR}/${MAPLE_SPRTA_TREE_PREFIX}${aln} --inputTree ${TREE_DIR}/${CMAPLE_SPRTA_TREE_PREFIX}${aln}.treefile --model ${MODEL} ${MAPLE_PARAMS} ${BL_FIXED_OPT} ${PRINT_LESS_INFO_SEQS_OPT}
    
    # move tree
    mv ${ALN_DIR}/${MAPLE_SPRTA_TREE_PREFIX}${aln}_nexusTree.tree ${TREE_DIR}
done
                        