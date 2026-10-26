#!/usr/bin/env bash
set -e

INSTANCE_ID=$(cd terraform && terraform output -raw instance_id)
PUBLIC_IP=$(cd terraform && terraform output -raw instance_public_ip)

echo "Setting up inventory for instance: $INSTANCE_ID"
printf "[webservers]\n%s\n" "$INSTANCE_ID" > ansible/inventory.ini

echo "=== 1. Waiting for SSM Agent on $INSTANCE_ID to become Online ==="
for i in {1..20}; do
    STATUS=$(aws ssm describe-instance-information --region eu-central-1 --query "InstanceInformationList[?InstanceId=='$INSTANCE_ID'].PingStatus" --output text)
    if [ "$STATUS" = "Online" ]; then
        echo "✓ Instance is Online in SSM!"
        break
    fi
    echo "Waiting for SSM connection... ($i/20)"
    sleep 5
done

echo "=== 2. Injecting SSH Public Key via SSM ==="
PUB_KEY=$(cat ~/.ssh/enterprise_key.pub)

aws ssm send-command \
  --instance-ids "$INSTANCE_ID" \
  --document-name "AWS-RunShellScript" \
  --comment "Inject SSH Key for Ansible" \
  --parameters commands="[\"mkdir -p /home/ubuntu/.ssh\",\"echo '$PUB_KEY' >> /home/ubuntu/.ssh/authorized_keys\",\"chown -R ubuntu:ubuntu /home/ubuntu/.ssh\",\"chmod 700 /home/ubuntu/.ssh\",\"chmod 600 /home/ubuntu/.ssh/authorized_keys\"]" \
  --region eu-central-1

echo "Waiting 10 seconds for SSH key application..."
sleep 10
