
# ==================================================
# Terraform Outputs
# ==================================================

# Output block ka use Terraform resources ki important
# information ko terminal me display karne ke liye hota hai.
#
# Jab hum terraform apply complete karte hain,
# to ye values automatically screen par show ho jaati hain.
#
# Example:
# terraform apply
#        ↓
# Resources Create
#        ↓
# Outputs Display


# ==================================================
# AWS Region Output
# ==================================================

output "region" {

  # Output ka description.
  # Ye documentation aur readability improve karta hai.
  description = "The AWS region where resources are created"

  # Local variable se region value fetch kar rahe hain.
  value = local.region
}


# ==================================================
# VPC ID Output
# ==================================================

output "vpc_id" {

  # Created VPC ki ID show karega.
  description = "The ID of the created VPC"

  # VPC module se VPC ID fetch kar rahe hain.
  value = module.vpc.vpc_id
}


# ==================================================
# EKS Cluster Name Output
# ==================================================

output "eks_cluster_name" {

  # Kubernetes cluster ka naam display karega.
  description = "EKS cluster name"

  # EKS module se cluster name le rahe hain.
  value = module.eks.cluster_name
}


# ==================================================
# EKS API Endpoint Output
# ==================================================

output "eks_cluster_endpoint" {

  # Kubernetes API Server ka endpoint URL.
  # Kubectl aur other tools isi endpoint se connect karte hain.
  description = "EKS cluster API endpoint"

  value = module.eks.cluster_endpoint
}


# ==================================================
# EC2 Public IP Output
# ==================================================

output "public_ip" {

  # EC2 server ka public IP display karega.
  description = "Public IP of the EC2 instance"

  # AWS instance resource se public IP fetch kar rahe hain.
  value = aws_instance.testinstance.public_ip
}


# ==================================================
# EKS Worker Nodes Public IPs
# ==================================================

output "eks_node_group_public_ips" {

  # EKS worker nodes ki public IP addresses display karega.
  description = "Public IPs of the EKS node group instances"

  # Data source se running worker nodes ki public IPs fetch kar rahe hain.
  value = data.aws_instances.eks_nodes.public_ips
}

