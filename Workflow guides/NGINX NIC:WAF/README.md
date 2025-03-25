# Protect Modern Apps against OWASP top 10 attacks using NGINX One for Kubernetes
=============================

## Table of Contents
- [Introduction](#introduction)
- [Architecture Diagram](#architecture-diagram)
- [Prerequisites](#prerequisites)
- [Assets](#assets)
- [Tools](#tools)
- [GitHub Secrets Configuration](#github-secrets-configuration)
  - [Required Secrets](#required-secrets)
  - [How to Add Secrets](#how-to-add-secrets)
- [Workflow Runs](#workflow-runs)
  - [STEP 1: Workflow Branches](#step-1-workflow-branches)
  - [STEP 2: Modify terraform.tfvars](#step-2-modify-terraformtfvars)
  - [STEP 3: Modify variable.tf](#step-3-modify-variabltf)
  - [STEP 4: Modify Backend.tf](#step-4-modify-backendtf)
  - [STEP 5: Set Bucket Name](#step-5-set-bucket-name)
  - [STEP 6: Commit and Push](#step-6-commit-and-push)
  - [STEP 7: Verify Assets](#step-7-verify-assets)
- [Development](#development)
- [Support](#support)
- [Community Code of Conduct](#community-code-of-conduct)
- [License](#license)
- [Copyright](#copyright)

## Introduction
---------------
This demo guide offers a step-by-step walkthrough for configuring the NGINX Ingress Controller with NGINX App Protect v5 on AWS Cloud, using Terraform scripts to automate the deployment. For more information, refer to the devcentral article:  <Coming Soon>

--------------

## Architecture Diagram
![System Architecture](Assets/AWS.jpeg)

## Prerequisites
* [NGINX Plus with App Protect and NGINX Ingress Controller license](https://www.nginx.com/free-trial-request/)
* [AWS Account](https://aws.amazon.com) - Due to the assets being created, the free tier will not work.
* [GitHub Account](https://github.com)

## Assets
* **nap:**       NGINX Ingress Controller for Kubernetes with NGINX App Protect (WAF and API Protection)
* **infra:**     AWS Infrastructure (VPC, IGW, etc.)
* **eks:**       AWS Elastic Kubernetes Service
* **arcadia:**   Arcadia Finance test web application and API
* **policy:**    NGINX WAF Compiler Docker and Policy
* **S3:**        Amazon S3 bucket and IAM role and policy for storage.

## Tools
* **Cloud Provider:** AWS
* **IAC:** Terraform
* **IAC State:** Amazon S3
* **CI/CD:** GitHub Actions

## GitHub Secrets Configuration

This workflow requires the following secrets to be configured in your GitHub repository:

### Required Secrets

| Secret Name            | Type    | Description                                                                 | Example Value/Format        |
|------------------------|---------|-----------------------------------------------------------------------------|----------------------------|
| `AWS_ACCESS_KEY_ID`     | Secret  | AWS IAM user access key ID with sufficient permissions                     | `AKIAXXXXXXXXXXXXXXXX`     |
| `AWS_SECRET_ACCESS_KEY` | Secret  | Corresponding secret access key for the AWS IAM user                       | (40-character mixed case string) |
| `AWS_SESSION_TOKEN`     | Secret  | Session token for temporary AWS credentials (if using MFA)                 | (Base64-encoded string)    |
| `NGINX_JWT`             | Secret  | JSON Web Token for NGINX license authentication                            | `eyJhbGciOi...` (JWT format) |
| `NGINX_CRT`             | Secret  | NGINX Certificate in PKCS#12 format                                        | `api.p12` file contents    |
| `NGINX_KEY`             | Secret  | Private key for securing HTTPS and verifying SSL/TLS certificates          | YourCertificatePrivatekey  |

### How to Add Secrets

1. Navigate to your GitHub repository
2. Go to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Enter the secret name exactly as shown above
5. Paste the secret value
6. Click **Add secret**

## Workflow Runs

### STEP 1: Workflow Branches
**DEPLOY**
  | Workflow     | Branch Name      |
  | ------------ | ---------------- |
  | NGINX V5-NIC/NAP Apply| apply-NIC/NAP   |

**DESTROY**
  | Workflow     | Branch Name       |
  | ------------ | ----------------- |
  | NGINX V5-NIC/NAP Destroy| destroy-NIC/NAP   |

### STEP 2: Modify terraform.tfvars
Rename `infra/terraform.tfvars.examples` to `infra/terraform.tfvars` and add the following data:
  * project_prefix  = "Your project identifier name in **lower case** letters only - this will be applied as a prefix to all assets"
  * resource_owner = "Your-name"
  * aws_region     = "AWS Region" ex. us-east-1
  * azs            = ["us-east-1a", "us-east1b"] - Change to Correct Availability Zones based on selected Region

### STEP 3: Modify variable.tf
Modify the `S3/variable.tf` file inside the `S3 directory`:
  * default     = "your-unique-bucket-name"  # Replace with your actual bucket name

### STEP 4: Modify Backend.tf
Modify the `Backend.tf` file in the `Infra/Backend.tf`, `eks-cluster/Backend.tf`, `Nap/Backend.tf`, `Policy/Backend.tf`, `Arcadia/Backend.tf` directory. 
  * bucket         = "your-unique-bucket-name"  # Your S3 bucket name
  * key            = "infra/terraform.tfstate"       # Path to state file
  * region         = "your-aws-region-name"   By default us-east-1

### STEP 5: Set Bucket Name
Add the name of your S3 bucket inside the `NGINX V5-NIC/NAP Destroy` workflow file, which is located in the Terraform _S3 job:
  *      name: Set Bucket Name
  *      id: set_bucket
  *      run: |
  *        echo "bucket_name="your-unique-bucket-name" >> $GITHUB_OUTPUT

### STEP 6: Commit and Push
Commit and push your build branch to your forked repo.  
The build will run and can be monitored in the GitHub Actions tab and TF Cloud console.

### STEP 7: Verify Assets
Once the pipeline is complete, verify that your assets were deployed or destroyed based on your workflow.  
**NOTE:** The autocert process takes time. It may be 5 to 10 minutes before Let's Encrypt has provided the cert.

## Development
Outline any requirements to set up a development environment if someone would like to contribute. You may also link to another file for this information.

## Support
For support, please open a GitHub issue. Note, the code in this repository is community-supported and is not supported by F5 Networks.

## Community Code of Conduct
Please refer to the [F5 DevCentral Community Code of Conduct](code_of_conduct.md).

## License
[Apache License 2.0](LICENSE)

## Copyright
Copyright 2014-2020 F5 Networks Inc.

### F5 Networks Contributor License Agreement
Before you start contributing to any project sponsored by F5 Networks, Inc. (F5) on GitHub, you will need to sign a Contributor License Agreement (CLA).
