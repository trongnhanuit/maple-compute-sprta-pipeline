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
        booleanParam(defaultValue: true, description: 'Download MAPLE', name: 'DOWNLOAD_MAPLE'),
    ])
])
pipeline {
    agent any
    environment {
        NCI_ALIAS = "gadi"
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
    }
    stages {
    	stage("Build CMAPLE") {
            steps {
                script {
                	if (params.BUILD_CMAPLE) {
                        echo 'Building CMAPLE'
                        // trigger jenkins cmaple-build
                        build job: 'cmaple-build', parameters: [string(name: 'BRANCH', value: CMAPLE_BRANCH)]

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
                        booleanParam(name: 'BLENGTHS_FIXED', value: BLENGTHS_FIXED),]

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
                	if (params.BLENGTHS_FIXED) {
                			sh "scp -r /Users/nhan/DATA/tmp/maple/original/MAPLE/MAPLEv0.6.8_skipPreBlengthOpt.py ${NCI_ALIAS}:${MAPLE_PATH}"
                		}
                    sh """
                        ssh -tt ${NCI_ALIAS} << EOF
                                              
                        echo "Compute SPRTA by MAPLE"
                        sh ${SCRIPTS_DIR}/maple_compute_sprta.sh ${ALN_DIR} ${TREE_DIR} ${MAPLE_PATH} ${CMAPLE_SPRTA_TREE_PREFIX} ${MAPLE_SPRTA_TREE_PREFIX} ${params.MODEL} ${params.BLENGTHS_FIXED}

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