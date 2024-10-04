//  a JenkinsFile to build iqtree
// paramters
//  1. git branch
// 2. git url


properties([
    parameters([
    	booleanParam(defaultValue: false, description: 'Re-build CMAPLE?', name: 'BUILD_CMAPLE'),
        string(name: 'CMAPLE_BRANCH', defaultValue: 'main', description: 'Branch to build CMAPLE'),
        booleanParam(defaultValue: false, description: 'Download testing data?', name: 'DOWNLOAD_DATA'),
        booleanParam(defaultValue: false, description: 'Infer ML trees?', name: 'INFER_TREE'),
        booleanParam(defaultValue: false, description: 'Compute SPRTA by CMAPLE?', name: 'COMPUTE_SPRTA_CMAPLE'),
        string(name: 'MODEL', defaultValue: 'GTR', description: 'Substitution model'),
        booleanParam(defaultValue: false, description: 'Blengths fixed?', name: 'BLENGTHS_FIXED'),
        booleanParam(defaultValue: false, description: 'Do not reroot?', name: 'NOT_REROOT'),
        booleanParam(defaultValue: true, description: 'Compute supports for branches with a length of zero?', name: 'ZERO_LENGTH_BRANCHES'),
        booleanParam(defaultValue: false, description: 'Output alternative SPRs?', name: 'OUT_ALT_SPR'),
        booleanParam(defaultValue: true, description: 'Download MAPLE', name: 'DOWNLOAD_MAPLE'),
        booleanParam(defaultValue: false, description: 'Use CIBIV cluster?', name: 'USE_CIBIV'),
    ])
])
pipeline {
    agent any
    environment {
        NCI_ALIAS = "gadi"
        SSH_COMP_NODE = " "
        WORKING_DIR = "/scratch/dx61/tl8625/cmaple/ci-cd"
        DATA_DIR = "${WORKING_DIR}/data"
        ALN_DIR = "${DATA_DIR}/aln"
        TREE_DIR = "${DATA_DIR}/tree"
        SCRIPTS_DIR = "${WORKING_DIR}/scripts"
        MAPLE_REPO_NAME = "MAPLE"
        MAPLE_REPO_URL = "https://github.com/NicolaDM/${MAPLE_REPO_NAME}.git"
        MAPLE_COMMIT_ID = "56ad091"
        MAPLE_VERSION = "MAPLEv0.6.8.py"
        MAPLE_PATH = "${WORKING_DIR}/${MAPLE_REPO_NAME}/${MAPLE_VERSION}"
        CMAPLE_SPRTA_TREE_PREFIX = "SPRTA_CMAPLE_tree_"
        MAPLE_SPRTA_TREE_PREFIX = "SPRTA_MAPLE_tree_"
        PYPY_PATH="/scratch/dx61/tl8625/tmp/pypy3.10-v7.3.17-linux64/bin/pypy3.10"
    }
    stages {
        stage('Init variables') {
            steps {
                script {
                    if (params.USE_CIBIV) {
                        NCI_ALIAS = "eingang"
                        SSH_COMP_NODE = " ssh -tt cox "
                        WORKING_DIR = "/project/AliSim/cmaple"
                        
                        DATA_DIR = "${WORKING_DIR}/data"
                        ALN_DIR = "${DATA_DIR}/aln"
                        TREE_DIR = "${DATA_DIR}/tree"
                        SCRIPTS_DIR = "${WORKING_DIR}/scripts"
                        MAPLE_PATH = "${WORKING_DIR}/${MAPLE_REPO_NAME}/${MAPLE_VERSION}"
                        PYPY_PATH="/project/AliSim/tools/pypy3.10-v7.3.17-linux64/bin/pypy3.10"
                        
                    }
                }
            }
        }
    	stage("Build CMAPLE") {
            steps {
                script {
                	if (params.BUILD_CMAPLE) {
                        echo 'Building CMAPLE'
                        // trigger jenkins cmaple-build
                        build job: 'cmaple-build', parameters: [string(name: 'BRANCH', value: CMAPLE_BRANCH),
                        booleanParam(name: 'USE_CIBIV', value: USE_CIBIV),]

                    }
                    else {
                        echo 'Skip building CMAPLE'
                    }
                }
            }
        }
        stage("Download testing data & Infer ML trees") {
            steps {
                script {
                	if (params.DOWNLOAD_DATA || params.INFER_TREE) {
                        // trigger jenkins cmaple-tree-inference
                        build job: 'cmaple-tree-inference', parameters: [booleanParam(name: 'DOWNLOAD_DATA', value: DOWNLOAD_DATA),
                        booleanParam(name: 'INFER_TREE', value: INFER_TREE),
                        string(name: 'MODEL', value: MODEL),
                        booleanParam(name: 'USE_CIBIV', value: USE_CIBIV),
                        ]
                    }
                    else {
                        echo 'Skip inferring ML trees'
                    }
                }
            }
        }
        stage('Compute SPRTA by CMAPLE') {
            steps {
                script {
                	if (params.COMPUTE_SPRTA_CMAPLE) {
                        echo 'Compute SPRTA by CMAPLE'
                        // trigger jenkins cmaple-build
                        build job: 'cmaple-compute-sprta', parameters: [string(name: 'MODEL', value: MODEL),
                        booleanParam(name: 'BLENGTHS_FIXED', value: BLENGTHS_FIXED),
                        booleanParam(name: 'NOT_REROOT', value: NOT_REROOT),
                        booleanParam(name: 'USE_CIBIV', value: USE_CIBIV),
                        booleanParam(name: 'ZERO_LENGTH_BRANCHES', value: ZERO_LENGTH_BRANCHES),
                        booleanParam(name: 'OUT_ALT_SPR', value: OUT_ALT_SPR),]

                    }
                    else {
                        echo 'Skip computing SPRTA by CMAPLE'
                    }
                }
            }
        }
        stage('Download MAPLE') {
            steps {
                script {
                if (params.DOWNLOAD_MAPLE) {
                	sh """
                        ssh -tt ${NCI_ALIAS} << EOF
                        mkdir -p ${WORKING_DIR}
                        cd  ${WORKING_DIR}
                        git clone ${MAPLE_REPO_URL}
                        cd  ${WORKING_DIR}/${MAPLE_REPO_NAME}
                        git reset --hard ${MAPLE_COMMIT_ID}
                        exit
                        EOF
                        """
                        if (params.NOT_REROOT)
                        {
                        	sh "scp -r /Users/nhan/DATA/tmp/maple/original/MAPLE/MAPLEv0.6.8_skipPreBlengthOpt.py ${NCI_ALIAS}:${MAPLE_PATH}"
                        }
                    	else
                    	{
                    		sh "scp -r /Users/nhan/DATA/tmp/maple/original/MAPLE/MAPLEv0.6.8_skipPreBlengthOpt_wo_MAT.py ${NCI_ALIAS}:${MAPLE_PATH}"
                    	}
                    }
                    else {
                        echo 'Skip downloading MAPLE'
                    }
                }
            }
        }
        stage('Compute SPRTA by MAPLE') {
            steps {
                script {
                	sh """
                        ssh ${NCI_ALIAS} << EOF
                        mkdir -p ${SCRIPTS_DIR}
                        exit
                        EOF
                        """
                	sh "scp -r scripts/* ${NCI_ALIAS}:${SCRIPTS_DIR}"
                    sh """
                        ssh -tt ${NCI_ALIAS} ${SSH_COMP_NODE}<< EOF
                                              
                        echo "Compute SPRTA by MAPLE"
                        sh ${SCRIPTS_DIR}/maple_compute_sprta.sh ${ALN_DIR} ${TREE_DIR} ${MAPLE_PATH} ${CMAPLE_SPRTA_TREE_PREFIX} ${MAPLE_SPRTA_TREE_PREFIX} ${params.MODEL} ${params.BLENGTHS_FIXED} ${params.NOT_REROOT} ${PYPY_PATH} ${params.ZERO_LENGTH_BRANCHES} ${params.OUT_ALT_SPR}

                        exit
                        EOF
                        """
                }
            }
        }
        stage ('Verify') {
            steps {
                script {
                	sh """
                        ssh -tt ${NCI_ALIAS} << EOF
                        cd  ${WORKING_DIR}
                        echo "Files in ${WORKING_DIR}"
                        ls -ila ${WORKING_DIR}
                        echo "Files in ${ALN_DIR}"
                        ls -ila ${ALN_DIR}
                        echo "Files in ${TREE_DIR}"
                        ls -ila ${TREE_DIR}
                        exit
                        EOF
                        """
                }
            }
        }


    }
    post {
        always {
            echo 'Cleaning up workspace'
            cleanWs()
        }
    }
}

def void cleanWs() {
    // ssh to NCI_ALIAS and remove the working directory
    // sh "ssh -tt ${NCI_ALIAS} 'rm -rf ${REPO_DIR} ${BUILD_SCRIPTS}'"
}