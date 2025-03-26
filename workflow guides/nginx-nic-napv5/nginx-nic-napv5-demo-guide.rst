
NGINX Ingress Controller with App ProtectV5 in AWS Cloud Step-by-Step  Deployment Process:
====================================================================================================

This guide outlines deploying the NGINX Ingress controller and NGINX App Protect V5 alongside a demo application in AWS. It also explains how NGINX secures backend applications. 

1. Terraform Local Variables:  
*****************************


Step 1: Rename infra/terraform.tfvars.examples to infra/terraform.tfvars and add the following data

.. figure:: assets/add-lb.png


Step 4: Commit your changes

.. figure:: assets/add-lb.png


2. Policy:  
*****************************
The repo contains deafult policy named policy.json file located in policy folder. 

.. figure:: assets/policy-1.png

Users have the option to utilize the existing policy or, if preferred, create a custom policy. To do this, simply place the custom policy in the designated policy folder and name it "policy.json" or any name of your choosing. If you decide to use a different name, be sure to update the corresponding name in the workflow file accordingly.

.. figure:: assets/policy-2.png

3. Deployment Workflow:  
*****************************

Step 1: Check out a branch for the deploy workflow using the following naming convention

 * nic-napv5 deployment branch: apply-nic-napv5

.. figure:: assets/add-lb.png

Step 2: Push your deploy branch to the forked repo

.. figure:: assets/add-lb.png

Step 3: Back in GitHub, navigate to the Actions tab of your forked repo and monitor your build

.. figure:: assets/add-lb.png

Step 4: Once the pipeline completes, verify your assets were deployed to AWS 

.. figure:: assets/add-lb.png


3. Destroy Workflow:  
*****************************

Step 1: From your main branch, check out a new branch for the destroy workflow using the following naming convention

 * nic-napv5 destroy branch: destroy-nic-napv5

.. figure:: assets/add-lb.png

Step 2: Push your destroy branch to the forked repo

.. figure:: assets/add-lb.png

Step 3: Back in GitHub, navigate to the Actions tab of your forked repo and monitor your workflow

.. figure:: assets/add-lb.png

Step 4: Once the pipeline is completed, verify that your assets were destroyed

.. figure:: assets/add-lb.png


4. Validation
**************
Users can now access the application through the NGINX Ingress Controller Load Balancer, which enhances security for the backend application by implementing the configured Web Application Firewall (WAF) policies. This setup not only improves accessibility but also ensures that the application is protected from various web threats.

.. figure:: assets/lb-domain-access.png

With malicious attacks:
***********************
 

.. figure:: assets/sql-inj.png

Verify that the Cross Site scripting is detected and blocked by NGINX App Protect.

.. figure:: assets/sql-inj-detect.png

Conclusion:  
******************

This article outlines deploying a robust security framework using the NGINX Ingress Controller and NGINX App Protect WAF version 5 for a sample web application hosted on AWS EKS. We leveraged the NGINX Automation Examples Repository and integrated it into a CI/CD pipeline for streamlined deployment. Although the provided code and security configurations are foundational and may not cover every possible scenario, they serve as a valuable starting point for implementing NGINX Ingress Controller and NGINX App Protect version 5 in your own cloud environments.


