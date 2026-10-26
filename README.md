# End-to-End Enterprise AWS Environment Provisioning

[![Terraform](https://img.shields.io/badge/Terraform-1.17-623CE4?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Ansible](https://img.shields.io/badge/Ansible-2.16-EE0000?logo=ansible&logoColor=white)](https://www.ansible.com/)
[![Jenkins](https://img.shields.io/badge/Jenkins-CI%2FCD-D24939?logo=jenkins&logoColor=white)](https://www.jenkins.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-232F3E?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![Nginx](https://img.shields.io/badge/Nginx-Web_Server-009639?logo=nginx&logoColor=white)](https://nginx.org/)

A fully automated, production-grade DevOps pipeline combining **Infrastructure as Code (IaC)**, **Zero-Trust Configuration Management**, and **Continuous Integration/Continuous Deployment (CI/CD)**.

---

## 🌟 Key Features

* **Infrastructure as Code (Terraform):** Automated provisioning of custom VPC (10.0.0.0/16), Public Subnet (10.0.1.0/24), Internet Gateway, Route Tables, and Security Groups.
* **Keyless Zero-Trust Architecture:** Eliminates static SSH keys and avoids opening public SSH ports (Port 22). All server communication and Ansible configuration run through **AWS Systems Manager (SSM)**.
* **Automated Configuration Management (Ansible):** Dynamic server configuration, operating system updates, server hardening, and Nginx deployment.
* **Full CI/CD Automation (Jenkins):** A declarative multi-stage pipeline managing end-to-end checkout, provisioning, configuration, smoke testing, and on-demand teardown.

---

## 🚀 CI/CD Pipeline Stages

1. **Checkout Code:** Pulls latest commit from GitHub repository.
2. **Terraform Execution:** Automatically plans and applies infrastructure changes (`apply`) or tears them down (`destroy`).
3. **Setup SSM & Dynamic Inventory:** Waits for EC2 to register as Online in AWS SSM and injects ephemeral keys securely.
4. **Ansible Configuration:** Executes playbooks to update system packages and configure Nginx web server.
5. **Smoke Test & Health Check:** Verifies web server availability with `curl` to guarantee zero-downtime provisioning.

---

## 👨‍💻 Implemented By

* **Author:** Mikhail Farag
* **Special Thanks:** Senior Steps & Eng. Gamal Mohamed
