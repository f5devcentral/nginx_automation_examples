


Terraform Local Variables:
Step 1: Rename infra/terraform.tfvars.examples to infra/terraform.tfvars and add the following data

.. figure:: assets/add-lb.png


Step 4: Commit your changes

.. figure:: assets/add-lb.png


Deployment Workflow:
Step 1: Check out a branch for the deploy workflow using the following naming convention

 * nic-napv5 deployment branch: apply-nic-napv5

.. figure:: assets/add-lb.png

Step 2: Push your deploy branch to the forked repo

.. figure:: assets/add-lb.png

Step 3: Back in GitHub, navigate to the Actions tab of your forked repo and monitor your build

.. figure:: assets/add-lb.png

Step 4: Once the pipeline completes, verify your assets were deployed to AWS 

.. figure:: assets/add-lb.png



Destroy Workflow:
Step 1: From your main branch, check out a new branch for the destroy workflow using the following naming convention

 * nic-napv5 destroy branch: destroy-nic-napv5

.. figure:: assets/add-lb.png

Step 2: Push your destroy branch to the forked repo

.. figure:: assets/add-lb.png

Step 3: Back in GitHub, navigate to the Actions tab of your forked repo and monitor your workflow

.. figure:: assets/add-lb.png

Step 4: Once the pipeline completes, verify your assets were destroyed

.. figure:: assets/add-lb.png

Conclusion:
This article outlines the process of deploying a robust security framework using the NGINX Ingress Controller and NGINX App Protect WAF version 5 for a sample web application hosted on AWS EKS. We leveraged the NGINX Automation Examples Repository and integrated it into a CI/CD pipeline for streamlined deployment. Although the provided code and security configurations are foundational and may not cover every possible scenario, they serve as a valuable starting point for implementing NGINX Ingress Controller and NGINX App Protect version 5 in your own cloud environments.


