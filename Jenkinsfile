pipeline {
    agent any

    parameters {
        choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Choose whether to Deploy (apply) or Teardown (destroy) infrastructure')
    }

    environment {
        AWS_DEFAULT_REGION = 'eu-central-1'
    }

    stages {
        stage('1. Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('2. Terraform Execution') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    script {
                        if (params.ACTION == 'destroy') {
                            echo "⚠️ TEARING DOWN AWS INFRASTRUCTURE..."
                            sh 'terraform destroy -auto-approve'
                        } else {
                            echo "🚀 PROVISIONING AWS INFRASTRUCTURE..."
                            sh 'terraform apply -auto-approve'
                        }
                    }
                }
            }
        }

        stage('3. Setup SSM & Inventory') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                sh './setup_instance.sh'
            }
        }

        stage('4. Ansible Configuration') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                dir('ansible') {
                    sh 'ansible-playbook playbook.yml'
                }
            }
        }

        stage('5. Smoke Test & Health Check') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                sh '''
                    PUBLIC_IP=$(cd terraform && terraform output -raw instance_public_ip)
                    echo "Checking website at: http://$PUBLIC_IP"
                    curl -Is http://$PUBLIC_IP | head -n 1
                    echo "================================================="
                    echo "🚀 DEPLOYMENT SUCCESSFUL!"
                    echo "Visit your live website at: http://$PUBLIC_IP"
                    echo "================================================="
                '''
            }
        }
    }

    post {
        success {
            script {
                if (params.ACTION == 'destroy') {
                    echo "✓ ALL AWS RESOURCES SUCCESSFULLY DESTROYED & CLEANED UP!"
                } else {
                    echo "✓ ALL STAGES PASSED SUCCESSFULLY!"
                }
            }
        }
    }
}
