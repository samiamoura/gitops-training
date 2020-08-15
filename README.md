# GitOps Training

![Capture d’écran 2020-08-15 à 22 09 40](https://user-images.githubusercontent.com/58267422/90320755-13bac980-df44-11ea-8bc1-b72398fe6628.png)


## General

This is a complete project to train with GitOps metodology.

This repository provides a complete automated environment to deploy a functional infrastructure on AWS Provider and then we help to configure it step by step to understand and train with GitOps concepts.

## Infrastructure

This tutorial, allow to deploy an infrastructure on AWS cloud. We will provision 4 EC2 servers with the following specifications :
- One GitLab CE hosted on a private EC2 host, with his own Docker registry,
- One Kubernetes cluster with one control plane node and two workers nodes.

This infrastructue is powered with Instrasdtructure as Code by AWS CloudFormation. We can use two type of files :
- [AWS CloudFormation Stack File](https://github.com/samiamoura/gitops-training/blob/master/aws-stack/stack-GitOps.yml), to deploy your infrastructure in a basic plateforme AWS Cloud,
- [AWS Educate CloudFormation Stack File](https://github.com/samiamoura/gitops-training/blob/master/aws-educate-stack/stack-GitOps-educate.yml), to deploy your infrastructure in a educative plateforme AWS Cloud.

To resume, these stack files use : 
- [AWS CloudFormation Stack File Description](https://github.com/samiamoura/gitops-training/tree/master/aws-stack) : AWS CLI, AWS Secret Manager, AWS IAM (instance profile), management Gitlab Registry certificate (generation end deployement)...
- [AWS Educate CloudFormation Stack File Description](https://github.com/samiamoura/gitops-training/tree/master/aws-educate-stack) : AWS IAM (instance profile), management Gitlab Registry certificate (generation end deployement)...

Every stack is detailed in depth. You can view more details about these stacks by clicking on [AWS CloudFormation Stack File Description](https://github.com/samiamoura/gitops-training/tree/master/aws-stack) or on [AWS Educate CloudFormation Stack File Description](https://github.com/samiamoura/gitops-training/tree/master/aws-educate-stack).

## Project

In this tutorial, we will view how to implement tool chain integration with two **GitOps** approachs :
- Pipeline CI/CD with push approach, 
- Pipeline CI/CD with pull approach.

## Article 

You can view a complete article and tutorial in the EazyTraining platform by Clicking **[GitOps Article](https://bit.ly/2BzEgYy)**.

You can also click on the following schema : 

[![Foo](https://user-images.githubusercontent.com/58267422/88659401-499f2780-d0d5-11ea-92b3-bfcfe02c53bf.png)](https://bit.ly/2BzEgYy)

## Tools

The tools used for this projet :
- AWS, AWS CLI, CloudFormation, IAM Instance roles, Secret Manager, EC2
- Docker 
- Kubernetes 
- GitLab
- FluxCD
