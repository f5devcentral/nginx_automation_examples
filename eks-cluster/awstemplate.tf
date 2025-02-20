# Create Launch Template for EKS Node Groups
resource "aws_launch_template" "docker_install_template" {  # Renamed resource
  name_prefix   = "${local.project_prefix}-docker-install-"
  image_id      = data.aws_ami.amazon_linux_2_dynamic.id  # Updated reference

  instance_type = "t3.medium"  # Specify your desired instance type

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras install docker -y
    systemctl start docker
    systemctl enable docker
  EOF

  lifecycle {
    create_before_destroy = true
  }

  # Specify the IAM instance profile for the nodes
  iam_instance_profile {
    name = aws_iam_instance_profile.workernodes.name
  }

  # Optional: Add tags to the launch template
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${local.project_prefix}-docker-instance"
    }
  }

  depends_on = [
    aws_eks_node_group.private-node-group-1-tf,
    aws_eks_node_group.private-node-group-2-tf,
  ]
}

# Data resource for dynamic AMI ID
data "aws_ami" "amazon_linux_2_dynamic" {  # Renamed data resource
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

