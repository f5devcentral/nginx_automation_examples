# NGINX Automation Deployment Examples


## Getting Started

## Prerequisites

* [NGINX Plus with App Protect and NGINX Ingress Controller license](https://www.nginx.com/free-trial-request/)
* [AWS Account](https://aws.amazon.com) - Due to the assets being created, free tier will not work.
  * The F5 BIG-IP AMI being used from the [AWS Marketplace](https://aws.amazon.com/marketplace) must be subscribed to your account
  * Please make sure resources like VPC and Elastic IP's are below the threshold limit in that aws region
* [GitHub Account](https://github.com)

## Assets

* **nap:**       NGINX Ingress Controller for Kubernetes with NGINX App Protect (WAF and API Protection)
* **infra:**     AWS Infrastructure (VPC, IGW, etc.)
* **eks:**       AWS Elastic Kubernetes Service
* **arcadia:**   Arcadia Finance test web application and API
* **policy:**    NGINX WAF Compiler Docker and Policy 

## Tools

* **Cloud Provider:** AWS
* **IAC:** Terraform
* **IAC State:** Amazon S3
* **CI/CD:** GitHub Actions

  
  **GITHUB:** Create secrets with the following values:

  | **Name**              | **Type**| **Description**                                                                                   |
  | --------------------- | -------- --------------------------------------------------------------------------------------------       |
  | AWS_ACCESS_KEY_ID     | Secrets | Your AWS Access Key ID                                                                            |
  | AWS_SECRET_ACCESS_KEY | Secrets | Your AWS Secret Access Key                                                                        |
  | AWS_SESSION_TOKEN     | Secrets | Your AWS Session Token                                                                            |
  | NGINX_JWT             | Secrets | Your NGINX JSON Web Token value associated with your NGINX license.                               |
  | NGINX_CRT             | Secrets | Your F5XC API certificate. Set this to **api.p12**                                                |
  | NGINX_KEY             | Secrets | Set this to the password you supplied when creating your F5 XC API certificate                    |



## Workflow Runs

**STEP 1:** Check out a branch for the workflow you wish to run using the following naming convention. 

  **DEPLOY**
  
  | Workflow     | Branch Name      |
  | ------------ | ---------------- |
  | NGINX-nap/nic| deploy-xc-bigip  |

 
  **DESTROY**
  
  | Workflow     | Branch Name       |
  | ------------ | ----------------- |
  | NGINX-nap/nic| destroy-xc-bigip  |



**STEP 2:** Rename `infra/terraform.tfvars.examples` to `infra/terraform.tfvars` and add the following data:
  * project_prefix  = "Your project identifier name in **lower case** letters only - this will be applied as a prefix to all assets"
  * resource_owner = "Your-name"
  * aws_region     = "AWS Region" ex. us-east-1
  * azs            = ["us-east-1a", "us-east1b"] - Change to Correct Availability Zones based on selected Region
  * Also update assets boolean value as per your work-flows



**STEP 5:** Commit and push your build branch to your forked repo
  * Build will run and can be monitored in the GitHub Actions tab and TF Cloud console


**STEP 6:** Once the pipeline is complete, verify that your assets were deployed or destroyed based on your workflow. 

            **NOTE:**  The autocert process takes time.  It may be 5 to 10 minutes before Let's Encrypt has provided the cert.


## Development

Outline any requirements to setup a development environment if someone would like to contribute.  You may also link to another file for this information.

## Support

For support, please open a GitHub issue.  Note, the code in this repository is community supported and is not supported by F5 Networks.  

## Community Code of Conduct

Please refer to the [F5 DevCentral Community Code of Conduct](code_of_conduct.md).

## License

[Apache License 2.0](LICENSE)

## Copyright

Copyright 2014-2020 F5 Networks Inc.

### F5 Networks Contributor License Agreement

Before you start contributing to any project sponsored by F5 Networks, Inc. (F5) on GitHub, you will need to sign a Contributor License Agreement (CLA).

If you are signing as an individual, we recommend that you talk to your employer (if applicable) before signing the CLA since some employment agreements may have restrictions on your contributions to other projects.
Otherwise by submitting a CLA you represent that you are legally entitled to grant the licenses recited therein.

If your employer has rights to intellectual property that you create, such as your contributions, you represent that you have received permission to make contributions on behalf of that employer, that your employer has waived such rights for your contributions, or that your employer has executed a separate CLA with F5.

If you are signing on behalf of a company, you represent that you are legally entitled to grant the license recited therein.
You represent further that each employee of the entity that submits contributions is authorized to submit such contributions on behalf of the entity pursuant to the CLA.
