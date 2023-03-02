# Automate bootstrapping a bare minimum Kubernetes Cluster in Ubuntu
### Note that due to t2.micro instance only allow limited Private IP address. You potentially cannot run any more pod. Either get a better Instances or Bare-Metal-Server. Or just directly use AWS EKS.

## Infrastructure Provisioning
Ensure both Terraform and AWS CLI is installed. 

Go to AWS Console get your API Key and enter it in AWS CLI under profile=admin c

Then run the following which would install 
<ul>
    <li>VPC with 6 subnets (3 private, 3 public)</li>
    <li>Internet gateway and route table</li>
    <li>Two EC2 install in public subnets</li>
    <li>Security Groups that allow SSH and HTTP</li>
    <li>RSA private file</li>
</ul>    

```bash
terraform init
terraform apply 
```

## Dynamic Provision for Ansible
Ensure the following is installed IF your local machine is Ubuntu else just change to whichever package manager that is supported

### Ensure Collections is also installed for Ansible
Remember to check AWS CLI profile=admin (or whatever you like)
and change the inventory.ini accordingly.

```bash
sudo apt install python3-pip
pip install ansible
ansible-galaxy collection install kubernetes.core
ansible-galaxy collection install amazon.aws
pip install boto
pip install botocore
```

Run the following command to ensure dynamic provision is enabled

```bash
ansible-inventory -i demo.aws_ec2.yml --graph
```

Run the Ansible playbook
```bash
ansible-playbook playbook.yaml
```

Get the command from either the bash console or in the master node saved as output.txt
Find the last two line which should look like below
SSH into worker node type the command that LOOK LIKE BELOW
```bash
sudo kubeadm join 10.0.101.130:6443 --token tmi5rj.sycy7e35noe3r9uj --discovery-token-ca-cert-hash sha256:fc3e413ffb113c536c2f91df6ad11e2da6eab0c49bf30bfd75e0320619ad8789 --cri-socket unix:///var/run/cri-dockerd.sock
```

