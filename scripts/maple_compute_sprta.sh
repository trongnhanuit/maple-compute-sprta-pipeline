#!bin/bash

###### handle arguments ######

ALN_DIR=$1 # aln dir
TREE_DIR=$2 # tree dir
MAPLE_PATH=$3 # path to CMAPLE executable
CMAPLE_SPRTA_TREE_PREFIX=$4 # The prefix of trees with SPRTA computed by CMAPLE
MAPLE_SPRTA_TREE_PREFIX=$5 # The prefix of trees with SPRTA computed by MAPLE
MAPLE_PARAMS="--SPRTA --overwrite --networkOutput --keepInputIQtreeSupports --doNotImproveTopology --doNotReroot" # MAPLE params
PYPY_PATH="/scratch/dx61/tl8625/tmp/pypy3.10-v7.3.17-linux64/bin/pypy3.10"


### pre steps #####



############
mkdir -p ${TREE_DIR}

for aln_path in "${ALN_DIR}"/*.maple; do
	aln=$(basename "$aln_path")
    echo "Compute SPRTA (by MAPLE) for the tree ${ML_TREE_PREFIX}${aln}.treefile inferred from ${aln}"
    echo "cd ${ALN_DIR} && ${PYPY_PATH} ${MAPLE_PATH} --input ${aln} --output ${ALN_DIR}/${MAPLE_SPRTA_TREE_PREFIX}${aln} --inputTree ${TREE_DIR}/${ML_TREE_PREFIX}${aln}.treefile ${MAPLE_PARAMS}"
    cd ${ALN_DIR} && ${PYPY_PATH} ${MAPLE_PATH} --input ${aln} --output ${ALN_DIR}/${MAPLE_SPRTA_TREE_PREFIX}${aln} --inputTree ${TREE_DIR}/${CMAPLE_SPRTA_TREE_PREFIX}${aln}.treefile ${MAPLE_PARAMS}
    
    # move tree
    mv ${ALN_DIR}/${MAPLE_SPRTA_TREE_PREFIX}${aln}_nexusTree.tree ${TREE_DIR}
done
                        