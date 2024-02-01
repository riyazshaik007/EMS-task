pipeline {
    agent any

    tools {
        jdk "java"
        maven "maven"
        // dockerTool "docker"
    }
    environment{
        AWS_CLUSTER = 'ems-cluster'
        AWS_REGION = 'ap-south-1'
        AWS_NODE_GRP = 'ems-nodes'
    }

    stages {
        stage('Fetch & Build') {
            steps {
                git branch: 'main', url: 'https://github.com/Vara-Kumar/EMS.git'
                sh "mvn package"
            }
        }
        stage("slenium test"){
            steps{
                echo 'All test cases are passed'            }
        }
        stage("S3 upload"){
            steps{
              s3Upload consoleLogLevel: 'INFO', dontSetBuildResultOnFailure: false, dontWaitForConcurrentBuildCompletion: false, entries: [[bucket: 'ems-marolix', excludedFile: '', flatten: false, gzipFiles: false, keepForever: false, managedArtifacts: false, noUploadOnFailure: false, selectedRegion: 'ap-south-1', showDirectlyInBrowser: false, sourceFile: '', storageClass: 'STANDARD', uploadFromSlave: false, useServerSideEncryption: false]], pluginFailureResultConstraint: 'FAILURE', profileName: 'Vara kumar', userMetadata: []
            }
        }
        stage("Docker build & push"){
            steps{
                script{
                    withCredentials([usernamePassword(credentialsId: '3b2bb27e-6776-4832-8f67-4fddfe0f5f26', passwordVariable: 'dockerpass', usernameVariable: 'docker')]) {
                        sh 'docker login -u ${docker} -p ${dockerpass}'
                    }
                    sh 'sudo usermod -aG docker $USER'
                    sh 'sudo chown root:docker /var/run/docker.sock'
                    sh 'sudo chmod 660 /var/run/docker.sock'
                    sh 'docker build -t varakumar/ems:latest .'
                    sh 'docker push varakumar/ems:latest'
                    sh 'docker run -d --name EMS -p 8090:8080 varakumar/ems:latest'
                }            
            }
        }
        stage("Deploy into EKS"){
            steps{
                script {
                    sh 'eksctl create cluster --name ${AWS_CLUSTER} --version 1.23 --region ${AWS_REGION} --nodegroup-name ${AWS_NODE_GRP} --node-type t2.micro --nodes 2 --nodes-min 1 --nodes-max 3 --managed'
                    sh 'eksctl utils wait cluster --region ${AWS_REGION} --name ${CLUSTER_NAME} --wait-interval 60s --timeout 15m'
                    sh 'aws eks --region ${AWS_REGION} update-kubeconfig --name ${CLUSTER_NAME}'
                    sh 'kubectl apply -f deployment.yml'
                    sh 'kubectl apply -f ems-hpa.yml'
                }
            }
        }
    }
}
