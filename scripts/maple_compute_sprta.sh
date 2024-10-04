#!bin/bash

###### handle arguments ######

ALN_DIR=$1 # aln dir
TREE_DIR=$2 # tree dir
MAPLE_PATH=$3 # path to CMAPLE executable
CMAPLE_SPRTA_TREE_PREFIX=$4 # The prefix of trees with SPRTA computed by CMAPLE
MAPLE_SPRTA_TREE_PREFIX=$5 # The prefix of trees with SPRTA computed by MAPLE
MODEL=$6 # Substitution model
BLENGTHS_FIXED=$7 # keep blengths fixed or not
NOT_REROOT=$8 # whether we can reroot the tree
PYPY_PATH=$9 # path to pypy
ZERO_LENGTH_BRANCHES=${10} #  compute supports for branches with a length of zero
OUT_ALT_SPR=${11} # True to output alternative SPRs 

BL_FIXED_OPT=""
if [ "${BLENGTHS_FIXED}" = true ]; then
  BL_FIXED_OPT=" --blfix"
fi

NOT_REROOT_OPT=""
if [ "${NOT_REROOT}" = true ]; then
  NOT_REROOT_OPT=" --doNotReroot"
fi

ZERO_LENGTH_BRANCHES_OPT=""
if [ "${ZERO_LENGTH_BRANCHES}" = true ]; then
  ZERO_LENGTH_BRANCHES_OPT=" --supportFor0Branches --supportForIdenticalSequences"
fi

OUT_ALT_SPR_OPT=""
if [ "${OUT_ALT_SPR}" = true ]; then
  OUT_ALT_SPR_OPT=" --networkOutput"
fi

MAPLE_PARAMS="--SPRTA --overwrite --keepInputIQtreeSupports --doNotImproveTopology " # MAPLE params


### pre steps #####



############
mkdir -p ${TREE_DIR}
# remove old results
rm -f ${TREE_DIR}/${MAPLE_SPRTA_TREE_PREFIX}${aln}_*.tree

for aln_path in "${ALN_DIR}"/*.maple; do
	aln=$(basename "$aln_path")
    echo "Compute SPRTA (by MAPLE) for the tree ${ML_TREE_PREFIX}${aln}.treefile inferred from ${aln}"
    echo "cd ${ALN_DIR} && ${PYPY_PATH} ${MAPLE_PATH} --input ${aln} --output ${ALN_DIR}/${MAPLE_SPRTA_TREE_PREFIX}${aln} --inputTree ${TREE_DIR}/${CMAPLE_SPRTA_TREE_PREFIX}${aln}.treefile.nexus --model ${MODEL} ${MAPLE_PARAMS} ${BL_FIXED_OPT} ${NOT_REROOT_OPT} ${ZERO_LENGTH_BRANCHES_OPT} ${OUT_ALT_SPR_OPT}"
    cd ${ALN_DIR} && ${PYPY_PATH} ${MAPLE_PATH} --input ${aln} --output ${ALN_DIR}/${MAPLE_SPRTA_TREE_PREFIX}${aln} --inputTree ${TREE_DIR}/${CMAPLE_SPRTA_TREE_PREFIX}${aln}.treefile.nexus --model ${MODEL} ${MAPLE_PARAMS} ${BL_FIXED_OPT} ${NOT_REROOT_OPT} ${ZERO_LENGTH_BRANCHES_OPT} ${OUT_ALT_SPR_OPT}
    
    # move tree
    mv ${ALN_DIR}/${MAPLE_SPRTA_TREE_PREFIX}${aln}_nexusTree.tree ${TREE_DIR}
done
                        