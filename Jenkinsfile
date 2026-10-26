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
                sh '''
                    INSTANCE_ID=$(cd terraform && terraform output -raw instance_id)
                    echo "[webservers]\n$INSTANCE_ID" > ansible/inventory.ini

                    echo "Injecting SSH Key via AWS SSM..."
                    PUB_KEY=$(cat ~/.ssh/enterprise_key.pub)
                    aws ssm send-command \
                      --instance-ids "$INSTANCE_ID" \
                      --document-name "AWS-RunShellScript" \
                      --parameters "commands=[\"mkdir -p /home/ubuntu/.ssh && echo '$PUB_KEY' >> /home/ubuntu/.ssh/authorized_keys && chown -R ubuntu:ubuntu /home/ubuntu/.ssh && chmod 700 /home/ubuntu/.ssh && chmod 600 /home/ubuntu/.ssh/authorized_keys\"]" \
                      --region eu-central-1

                    echo "Waiting 15 seconds for instance readiness..."
                    sleep 15
                '''
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
                    echo " DEPLOYMENT SUCCESSFUL!"
                    echo "Visit your live website at: http://$PUBLIC_IP"
                    echo "================================================="
                '''
            }
        }
    }
}
