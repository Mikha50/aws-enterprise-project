pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'eu-central-1'
    }

    stages {
        stage('1. Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('2. Terraform Provision') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('3. Setup SSM & Inventory') {
            steps {
                sh './setup_instance.sh'
            }
        }

        stage('4. Ansible Configuration') {
            steps {
                dir('ansible') {
                    sh 'ansible-playbook playbook.yml'
                }
            }
        }

        stage('5. Smoke Test & Health Check') {
            steps {
                sh '''
                    PUBLIC_IP=$(cd terraform && terraform output -raw instance_public_ip)
                    echo "Checking website at: http://$PUBLIC_IP"
                    curl -Is http://$PUBLIC_IP | head -n 1
                    echo "================================================="
                    echo "   DEPLOYMENT SUCCESSFUL!"
                    echo "Visit your live website at: http://$PUBLIC_IP"
                    echo "================================================="
                '''
            }
        }
    }
}
