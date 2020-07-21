# Prerequisites

## Amazon Web Services

This tutorial leverages the [Amazon Web Services](https://aws.amazon.com/) to streamline provisioning of the compute infrastructure required to bootstrap GitOps environment.

> The compute resources required for this tutorial exceed the Amazon Web Services free tier. Make sure that you clean up the resource at the end of the activity to avoid incurring unwanted costs. 

## Amazon CloudFormation

AWS CloudFormation provides a common language for you to model and provision AWS and third party application resources in your cloud environment. CloudFormation allows you to use programming languages or a simple text file to model and provision, in an automated and secure manner, all the resources needed for your applications across all regions and accounts. This gives you a single source of truth for your AWS and non-AWS resources.

## Amazon Web Services CLI

To deploy resources, you need an AWS account, the role of administrator and programmatic access (access key ID and a secret access key).

## Amazon Web Services Roles 

This project uses [AMI roles](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html) as well and [instance profiles](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2_instance-profiles.html) for EC2 instances

### IAM Role 

For security reasons, we use the principle of least privilege to define roles and comply. We create two roles with specific policies:
- **ec2RoleDescribeInstanceGetSecret** : One role to allow description of EC2 instances and to allow get information only about secret specially created during this tutorial.
- **ec2RoleDescribeInstance** : One role to allow description of EC2 instances only 

### Instance Profiles role
We use this principle to attache role specially for desired instance
- The **ec2RoleDescribeInstanceGetSecret** is attached to GitLab instance and Kubernetes master with the name **ec2InstanceProfileDescribeInstanceGetSecret**
- The **ec2RoleDescribeInstance** is attached to Kubernetes worker nodes with the name **ec2InstanceProfileDescribeInstance**

## Amazon Web Services Secret Manager

For security reasons, you use [AWS Secret Manager](https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html) to store secrets.
In our case, we will store a private key generated in this tutorial to avoid to pass this sensitive information in clear in the CloudFormation stack file.

## Description of projet

It is a  CloudFormation stack that provides a complete environment for practicing the GitOps concepts. This uses AWS CloudFormation for infrastructure as code, the secret manager to store secrets securely, IAM roles and Instance profiles.

This stack provides a complete environment with a private GitLab instance with certificate management for the container registry and a functional Kubernetes cluster with 3 nodes. One master and two workers.

You just have to train on the gitops :blush:

## Infrastructure 

![38_schema_infra](https://user-images.githubusercontent.com/58267422/88068166-2245d900-cb70-11ea-9e67-e0fff8df6f8b.png)

<br>


# Deployment 

##  AWS Region 

In this tutorial, we will work exclusively in the AWS region ```us-east-1```. 
All the resources that will be deployed will be in this region. If you want to change the region remember to check that the images are available in the desired region.

## Operating System 

### Deployment instance

- In this tutorial, we use a **Linux Debian 9 (stretch)** distribution as an environment to provision all of the resources in AWS provider.
- Note that we will call this instance with **AWS CLI instance**
- All commands will be made from  **AWS CLI instance**  unless we specify otherwise. This will be explicitly mentioned in this tutorial

### User AWS CLI instance 

In this tutorial we will use **admin** to run all bash commands in all resources
```
export SSHUSER=admin
```

Put SSHUSER in **/etc/profile.d/environment-gitops.sh** to avoid running the previous command every time after you logout 
```
echo 'export SSHUSER=admin' | sudo tee -a /etc/profile.d/environment-gitops.sh 
```

### Resources Deployment

- In this tutorial, we deploy EC2 instances of **Linux Debian 9 (stretch)** distribution.
- It is possible to use a **Linux CentOS 7 distribution**. This should then be specified in the stack creation section.

## AWSCLI 2.x.x and git installation 

### AWSCLI 2.x.x installation 
AWS CLI versions 1 and 2 use the same aws command name. If you have both versions installed, your computer uses the first one found in your search path. If you previously installed AWS CLI version 1, we recommend that you do one of the following to use AWS CLI version 2.

**Recommended** : Uninstall AWS CLI version 1 and use only AWS CLI version 2.

```
sudo apt-get install unzip -y
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo unzip awscliv2.zip
sudo ./aws/install -i /usr/local/aws-cli -b /usr/local/bin
```

Verify AWS CLI version : 
```
aws --version

aws-cli/2.0.30 Python/3.7.3 Linux/4.9.0-8-amd64 botocore/2.0.0dev34
```

### Git installation 
```
sudo apt-get -y install git 
```

## Configure AWS 

Run ```aws configure``` to configure AWS :

```
AWS Acces Key ID :  YOUR ACCESS KEY ID
AWS Secret Access Key : YOUR SECRET ACCESS KEY
Default region name : eu-east-1
default output format : json
```
<br>

## SSH key pair

### Create a SSH key pair

```
export KEYNAME="my-key-gitops"

aws ec2 create-key-pair --key-name $KEYNAME --output text --query 'KeyMaterial' > $HOME/gitops.id_rsa

chmod 600 $HOME/gitops.id_rsa
```

### Verify SSH key pair has successfully created 

```
aws ec2 describe-key-pairs --key-name $KEYNAME
```

The result must be similar to :

```
{
    "KeyPairs": [
        {
            "KeyPairId": "key-0882a67d682b4eb6e",
            "KeyFingerprint": "1f:fb:30:fb:cf:70:4e:40:c1:77:6f:10:18:14:ef:9c:e7:cd:91:35",
            "KeyName": "my-key-gitops",
            "Tags": []
        }
    ]
}
```

### Verify private key file has successfully cretated as well 

```
ls -l $HOME/gitops.id_rsa

-rw------- 1 admin admin 1675 Jul 10 22:19 gitops.id_rsa
```
<br>

## AWS Secret Manager 

### Create a secret with AWS Secret Manager 

```
export SECRETNAME="my-gitops-secret-private-key"

aws secretsmanager create-secret --name $SECRETNAME \
--description "SSH Private key to establish connection in our ec2 instances deployed" \
--tags Key=Project,Value=gitops \
--secret-string file://$HOME/gitops.id_rsa
```

The result must be similar to : 

```
{
    "ARN": "arn:aws:secretsmanager:us-east-1:101390916346:secret:my-gitops-secret-private-key-D5MKCI",
    "Name": "my-gitops-secret-private-key",
    "VersionId": "b5e2ee31-b542-455b-aa69-fb52d5a0c755"
}
```

Get the Secret ARN :  

```
SECRETARN=$(aws secretsmanager describe-secret --secret-id $SECRETNAME --query "ARN" --output text)
```
<br>

## Get CloudFormation stack

Run the following command to download AWS CloudFormation stack : 
```
git clone https://github.com/samiamoura/gitops-training.git
```
<br>

## CloudFormation deployment 

### Define specifications of different resources

#### ImageType correspond OS type of EC2 Instances, two types are allowed :

- Debian GNU/Linux 9 (stretch) - ami-003f19e0e687de1cd
- CentOS Linux 7 (Core) - ami-0083662ba17882949

In this tutorial we use **Debian GNU/Linux 9 (stretch) - ami-003f19e0e687de1cd**. Run the following command : 
```
export IMAGETYPE="Debian GNU/Linux 9 (stretch) - ami-003f19e0e687de1cd"
```

Note : These Amazon Machine Images (AMI) are available for AWS region **us-east-1**

#### InstanceTypeGitLab correspond type of EC2 Instances of **GitLab Community Edition**, numerous types are allowed :
- t2.medium, t2.large, t2.xlarge, t2.2xlarge
- t3.nano, t3.micro, t3.small, t3.medium, t3.large, t3.xlarge, t3.2xlarge
- m4.large, m4.xlarge, m4.2xlarge, m4.4xlarge, m4.10xlarge
- m5.large, m5.xlarge, m5.2xlarge, m5.4xlarge
...

Recommanded value is mimimum **t2.medium**. Run the following command : 
```
export INSTANCETYPEGITLAB="t2.medium"
```

#### InstanceTypeKubernetesMaster correspond type of EC2 Instances for **Kubernetes master node**, numerous type are allowed :
- t2.medium, t2.large, t2.xlarge, t2.2xlarge
- t3.nano, t3.micro, t3.small, t3.medium, t3.large, t3.xlarge, t3.2xlarge
- m4.large, m4.xlarge, m4.2xlarge, m4.4xlarge, m4.10xlarge
- m5.large, m5.xlarge, m5.2xlarge, m5.4xlarge
...

Recommanded value is mimimum **t2.medium**. Run the following command : 

```
export INSTANCETYPEKUBERNETESMASTER="t2.medium"
```

#### InstanceTypeKubernetesWorker correspond type of EC2 Instances for **Kubernetes worker nodes**, numerous types are allowed :
- t2.medium, t2.large, t2.xlarge, t2.2xlarge
- t3.nano, t3.micro, t3.small, t3.medium, t3.large, t3.xlarge, t3.2xlarge
- m4.large, m4.xlarge, m4.2xlarge, m4.4xlarge, m4.10xlarge
- m5.large, m5.xlarge, m5.2xlarge, m5.4xlarge
...

Recommanded value is mimimum **t2.medium**. Run the following command : 
```
export INSTANCETYPEKUBERNETESWORKER="t2.medium"
```

#### Define AWS CloudFormation stack name :

Run the following command : 
```
export STACKNAME="my-stack-gitops"
```
<br>

## Create AWS CloudFormation stack 

```
aws cloudformation create-stack --stack-name $STACKNAME \
--template-body file://$HOME/gitops-training/aws-stack/stack-GitOps.yml \
--parameters ParameterKey=ImageType,ParameterValue="$IMAGETYPE" \
ParameterKey=InstanceTypeGitLab,ParameterValue="$INSTANCETYPEGITLAB" \
ParameterKey=InstanceTypeKubernetesMaster,ParameterValue="$INSTANCETYPEKUBERNETESMASTER" \
ParameterKey=InstanceTypeKubernetesWorker,ParameterValue="$INSTANCETYPEKUBERNETESWORKER" \
ParameterKey=KeyName,ParameterValue=$KEYNAME \
ParameterKey=SSHLocation,ParameterValue="0.0.0.0/0" \
ParameterKey=SecretARN,ParameterValue="$SECRETARN" \
ParameterKey=Secretname,ParameterValue="$SECRETNAME" \
--capabilities CAPABILITY_IAM
```

The result must be similar to : 

```
{
    "StackId": "arn:aws:cloudformation:us-east-1:101390916346:stack/my-stack-gitops/4f84ecc0-c2fc-11ea-b9f8-0e2470ba0d5b"
}
```

**Information : Time creating of all resources and environment working can be take 5-10 minutes. You can go take a coffee ....** :coffee: :sleeping:


<br>

## Retrieve information for all resources 

### Get all instance public IP addresses 
```
aws ec2 describe-instances \
--query "Reservations[*].Instances[*].{Instance:PublicIpAddress,Name:Tags[?Key=='Name']|[0].Value}" \
--filters Name=instance-state-name,Values=running Name=tag:Project,Values=gitops \
--output text | sort -k2
```

The result must be similar to : 

```
107.22.79.159	GitLabServer
52.87.110.104	KubernetesMaster
34.235.95.254	KubernetesWorker1
23.21.58.253	KubernetesWorker2
```
<br>

## Get individual instance Public IP address

### GitLab instance 

```
GitLabPublicIP=$(aws ec2 describe-instances \
--query "Reservations[*].Instances[*].{Instance:PublicIpAddress}" \
--filters Name=instance-state-name,Values=running Name=tag:Project,Values=gitops Name=tag:Name,Values=GitLabServer \
--output text)
```

Put the public IP address in **/etc/profile.d/environment-gitops.sh** to avoid running the previous command every time after you logout 
```
echo 'export GitLabPublicIP=$(aws ec2 describe-instances \
--query "Reservations[*].Instances[*].{Instance:PublicIpAddress}" \
--filters Name=instance-state-name,Values=running Name=tag:Project,Values=gitops Name=tag:Name,Values=GitLabServer \
--output text)' | sudo tee -a /etc/profile.d/environment-gitops.sh
```

### Kubernetes master node

```
KubernetesMasterPublicIP=$(aws ec2 describe-instances \
--query "Reservations[*].Instances[*].{Instance:PublicIpAddress}" \
--filters Name=instance-state-name,Values=running Name=tag:Project,Values=gitops Name=tag:Name,Values=KubernetesMaster \
--output text)
```

Put the public IP address in **/etc/profile.d/environment-gitops.sh** to avoid running the previous command every time after you logout 
```
echo 'export KubernetesMasterPublicIP=$(aws ec2 describe-instances \
--query "Reservations[*].Instances[*].{Instance:PublicIpAddress}" \
--filters Name=instance-state-name,Values=running Name=tag:Project,Values=gitops Name=tag:Name,Values=KubernetesMaster \
--output text)' | sudo tee -a /etc/profile.d/environment-gitops.sh
```

### Kubernetes worker node 1 

```
KubernetesWorker1PublicIP=$(aws ec2 describe-instances \
--query "Reservations[*].Instances[*].{Instance:PublicIpAddress}" \
--filters Name=instance-state-name,Values=running Name=tag:Project,Values=gitops Name=tag:Name,Values=KubernetesWorker1 \
--output text)
```

Put the public IP address in **/etc/profile.d/environment-gitops.sh** to avoid running the previous command every time after you logout 
```
echo 'export KubernetesWorker1PublicIP=$(aws ec2 describe-instances \
--query "Reservations[*].Instances[*].{Instance:PublicIpAddress}" \
--filters Name=instance-state-name,Values=running Name=tag:Project,Values=gitops Name=tag:Name,Values=KubernetesWorker1 \
--output text)' | sudo tee -a /etc/profile.d/environment-gitops.sh 
```

### Kubernetes worker node 2

```
KubernetesWorker2PublicIP=$(aws ec2 describe-instances \
--query "Reservations[*].Instances[*].{Instance:PublicIpAddress}" \
--filters Name=instance-state-name,Values=running Name=tag:Project,Values=gitops Name=tag:Name,Values=KubernetesWorker2 \
--output text)
```

Put the public IP address in **/etc/profile.d/environment-gitops.sh** to avoid running the previous command every time after you logout 
```
echo 'export KubernetesWorker2PublicIP=$(aws ec2 describe-instances \
--query "Reservations[*].Instances[*].{Instance:PublicIpAddress}" \
--filters Name=instance-state-name,Values=running Name=tag:Project,Values=gitops Name=tag:Name,Values=KubernetesWorker2 \
--output text)' | sudo tee -a /etc/profile.d/environment-gitops.sh 
```

### Retrieve instances Public IP address

#### Verify all IP address has been successfully affected to all variables 
```
declare -a array_ip=\
("GitLab=$GitLabPublicIP\n""KubernetesMaster=$KubernetesMasterPublicIP\n"\
"KubernetesWorker1=$KubernetesWorker1PublicIP\n""KubernetesWorker2=$KubernetesWorker2PublicIP")
echo -e ${array_ip[@]}
```

The result must be similar to : 

```
GitLab=107.22.79.159
KubernetesMaster=52.87.110.104
KubernetesWorker1=34.235.95.254
KubernetesWorker2=23.21.58.253
```
<br>

## SSH connection 

### Connect to EC2 instances using SSH

```
ssh -i "$HOME/gitops.id_rsa" $SSHUSER@$GitLabPublicIP
ssh -i "$HOME/gitops.id_rsa" $SSHUSER@$KubernetesMasterPublicIP
ssh -i "$HOME/gitops.id_rsa" $SSHUSER@$KubernetesWorker1PublicIP
ssh -i "$HOME/gitops.id_rsa" $SSHUSER@$KubernetesWorker2PublicIP
```
<br>


## Ensure environment working correctly 

### Ensure GitLab instance is working 

#### Connect to GitLab instance with the following command : 

```
ssh -i "$HOME/gitops.id_rsa" $SSHUSER@$GitLabPublicIP
```

#### Run ```docker ps -a``` to ensure Docker container are Up
```
docker ps -a
```
The result must be similar to : 

```
CONTAINER ID        IMAGE                                COMMAND                  CREATED             STATUS                      PORTS                                                            NAMES
ea6da2d5f127        gitlab/gitlab-runner:alpine-v9.3.0   "/usr/bin/dumb-init …"   5 minutes ago      Up 5 minutes                                                                                gitlab_runner
45a63c7a7012        gitlab/gitlab-ce:11.11.0-ce.0        "/assets/wrapper"        5 minutes ago      Up 5 minutes (healthy)     0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp, 0.0.0.0:2222->22/tcp   gitlab
39889864d5ac        gitlab/gitlab-runner:alpine-v9.3.0   "bash -c 'if [[ -r /…"   5 minutes ago      Exited (0) 2 minutes ago                                                                     gitlab_runner_register
```
**Note : Its normal the gitlab_runner_register container has exited with status code 0**

### Ensure Kubernetes cluster is working

#### From instance with AWS CLI, Connect to Kubernetes master : 

```
ssh -i "$HOME/gitops.id_rsa" $SSHUSER@$KubernetesMasterPublicIP
```

#### Run ```kubectl get nodes``` to ensure all Kubernetes nodes are presents and working as well in the cluster 

```
sudo su -

kubectl get nodes -o wide
```


The result must be similar to : 

```
NAME      STATUS   ROLES    AGE   VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                       KERNEL-VERSION   CONTAINER-RUNTIME
master    Ready    master   10m   v1.18.5   172.31.74.179   <none>        Debian GNU/Linux 9 (stretch)   4.9.0-8-amd64    docker://19.3.12
worker1   Ready    <none>   9m   v1.18.5   172.31.66.130   <none>        Debian GNU/Linux 9 (stretch)   4.9.0-8-amd64    docker://19.3.12
worker2   Ready    <none>   9m   v1.18.5   172.31.74.174   <none>        Debian GNU/Linux 9 (stretch)   4.9.0-8-amd64    docker://19.3.12
```

#### Create a pod and expose it as a service to ensure network is workin correctly

##### Create a pod nginx :
```
kubectl run nginx --image=nginx --restart=Never

pod/nginx created
```

##### Expose as a service NodePort the pod previoulsly cretaed :  
```
kubectl expose pod nginx --type=NodePort --port=80

service/nginx exposed
```

##### Retrieve informations of resources previously created 
```
kubectl get all
```

The result must be similar to : 

```
NAME        READY   STATUS    RESTARTS   AGE
pod/nginx   1/1     Running   0          3m29s

NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP        32m
service/nginx        NodePort    10.96.136.124   <none>        80:31695/TCP   31s
```

##### Test services working correcty on all Kubernetes nodes

###### Get NodePort of nginx service
```
NODE_PORT=$(kubectl get service nginx \
--output=jsonpath='{range .spec.ports[0]}{.nodePort}')
```

###### Get Private IP address of all Kubernetes nodes 
```
KubernetesMasterPrivateIP=$(/usr/local/bin/aws ec2 describe-instances \
--query "Reservations[*].Instances[*].[PrivateIpAddress]" \
--filters Name=tag:Name,Values=KubernetesMaster Name=instance-state-name,Values=running \
--output text)

KubernetesWorker1PrivateIP=$(/usr/local/bin/aws ec2 describe-instances \
--query "Reservations[*].Instances[*].[PrivateIpAddress]" \
--filters Name=tag:Name,Values=KubernetesWorker1 Name=instance-state-name,Values=running \
--output text)

KubernetesWorker2PrivateIP=$(/usr/local/bin/aws ec2 describe-instances \
--query "Reservations[*].Instances[*].[PrivateIpAddress]" \
--filters Name=tag:Name,Values=KubernetesWorker2 Name=instance-state-name,Values=running \
--output text)
```
###### Verify all IP address has been successfully affected to all variables 
```
declare -a array_ip=\
("KubernetesMaster=$KubernetesMasterPrivateIP\n"\
"KubernetesWorker1=$KubernetesWorker1PrivateIP\n""KubernetesWorker2=$KubernetesWorker2PrivateIP")
echo -e ${array_ip[@]}
```

The result must be similar to : 

```
KubernetesMaster=172.31.67.55
KubernetesWorker1=172.31.70.87
KubernetesWorker2=172.31.77.118
```

##### Test the ```nginx``` service can be reached thanks to the routing mesh principle for all Kubernetes nodes


##### From Kubernetes master, ensure the ```nginx``` service can be reached for Kubernetes master node
```
curl $KubernetesMasterPrivateIP:$NODE_PORT
```

##### From Kubernetes master, ensure the ```nginx``` service can be reached for Kubernetes worker 1 node
```
curl $KubernetesWorker1PrivateIP:$NODE_PORT
```
##### From Kubernetes master, ensure the ```nginx``` service can be reached for Kubernetes worker 2 node
```
curl $KubernetesWorker2PrivateIP:$NODE_PORT
```

For all Kubernetes nodes the result must be similar to :

```
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

### Ensure certficates of GitLab private container registry are present on all Kubernetes cluster nodes

#### From AWS CLI instance, connect to Kubernetes master : 

```
ssh -i "$HOME/gitops.id_rsa" $SSHUSER@$KubernetesMasterPublicIP
```

#### Ensure certificate is present

```
GitlabPublicDnsName=$(/usr/local/bin/aws ec2 describe-instances \
--query "Reservations[*].Instances[*].[PublicDnsName]" \
--filters Name=tag:Name,Values=GitLabServer Name=instance-state-name,Values=running \
--output text)

ls -l /etc/docker/certs.d/$GitlabPublicDnsName/ca.crt
```
The result must be similar to : 
```
-rw------- 1 admin admin 2069 Jul 11 01:18 /etc/docker/certs.d/ec2-52-206-185-161.compute-1.amazonaws.com/ca.crt
```

#### From AWS CLI instance, connect to Kubernetes worker1 : 

```
ssh -i "$HOME/gitops.id_rsa" $SSHUSER@$KubernetesWorker1PublicIP
```

#### Ensure certificate is present

```
GitlabPublicDnsName=$(/usr/local/bin/aws ec2 describe-instances \
--query "Reservations[*].Instances[*].[PublicDnsName]" \
--filters Name=tag:Name,Values=GitLabServer Name=instance-state-name,Values=running \
--output text)

ls -l /etc/docker/certs.d/$GitlabPublicDnsName/ca.crt
```
The result must be similar to : 
```
-rw------- 1 admin admin 2069 Jul 11 01:18 /etc/docker/certs.d/ec2-52-206-185-161.compute-1.amazonaws.com/ca.crt
```

#### From AWS CLI instance, connect to Kubernetes worker2 : 

```
ssh -i "$HOME/gitops.id_rsa" $SSHUSER@$KubernetesWorker2PublicIP
```

#### Ensure certificate is present

```
GitlabPublicDnsName=$(/usr/local/bin/aws ec2 describe-instances \
--query "Reservations[*].Instances[*].[PublicDnsName]" \
--filters Name=tag:Name,Values=GitLabServer Name=instance-state-name,Values=running \
--output text)

ls -l /etc/docker/certs.d/$GitlabPublicDnsName/ca.crt
```
The result must be similar to : 
```
-rw------- 1 admin admin 2069 Jul 11 01:18 /etc/docker/certs.d/ec2-52-206-185-161.compute-1.amazonaws.com/ca.crt
```

## Destroy resources

### Define name of resources 

```
export STACKNAME="my-stack-gitops"
SECRETNAME=$(aws secretsmanager list-secrets --query "SecretList[*].[Name]" \
--filters Key=tag-key,Values=Project Key=tag-value,Values=gitops \
--output text) 
export KEYNAME="my-key-gitops"
```

### Delete AWS CloudFormation stack 

```
aws cloudformation delete-stack --stack-name $STACKNAME
```

### Delete secret 

```
aws secretsmanager delete-secret --secret-id $SECRETNAME --recovery-window-in-days 7
```

The result must be similar to : 

```
{
    "ARN": "arn:aws:secretsmanager:us-east-1:101390916346:secret:my-gitops-secret-private-key-D5MKCI",
    "Name": "my-gitops-secret-private-key",
    "VersionId": "b5e2ee31-b542-455b-aa69-fb52d5a0c755"
}
```

### Delete key pair 

```
aws ec2 delete-key-pair --key-name $KEYNAME
```

### Delete private key file  

```
sudo rm -rf $HOME/gitops.id_rsa 
```

### Delete profile.d script file  

```
sudo rm -fr /etc/profile.d/environment-gitops.sh
