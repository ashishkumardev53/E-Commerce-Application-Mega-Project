
# ==================================================
# Terraform Variables
# ==================================================

# Variables Terraform me user input lene ke liye use hote hain.
#
# Variables ka use hardcoded values ko avoid karne ke liye kiya jata hai.
#
# Benefits:
# ✅ Reusable Code
# ✅ Easy Configuration
# ✅ Different Environments Support
# ✅ Better Maintainability
#
# Example:
#
# Dev Environment
# t2.medium
#
# Production Environment
# t3.large
#
# Sirf variable ki value change karni hogi,
# pura code change nahi karna padega.


# ==================================================
# AWS Region Variable
# ==================================================

variable "aws_region" {

  # Variable ka purpose explain karta hai.
  description = "AWS region where resources will be provisioned"

  # Default AWS Region
  #
  # Agar terraform apply ke time koi value pass nahi ki gayi,
  # to ye value automatically use hogi.
  #
  # us-east-2 = Ohio Region
  default = "us-east-2"
}


# ==================================================
# AMI ID Variable
# ==================================================

variable "ami_id" {

  # EC2 Instance ke liye kaunsi Operating System image use hogi.
  description = "AMI ID for the EC2 instance"

  # Default Ubuntu/Linux AMI ID
  #
  # AMI (Amazon Machine Image)
  # ek pre-configured Operating System template hoti hai.
  #
  # Iske andar:
  # - Operating System
  # - Pre-installed Packages
  # - Configurations
  #
  # Pehle se available hote hain.
  default = "ami-085f9c64a9b75eed5"
}


# ==================================================
# EC2 Instance Type Variable
# ==================================================

variable "instance_type" {

  # EC2 server ka size define karta hai.
  description = "Instance type for the EC2 instance"

  # Default Instance Type
  #
  # t2.medium generally provide karta hai:
  # - 2 vCPU
  # - 4 GB RAM
  #
  # Development aur small workloads ke liye useful.
  default = "t2.medium"
}


# ==================================================
# Environment Variable
# ==================================================

variable "my_enviroment" {

  # Environment identify karne ke liye.
  #
  # Note:
  # Variable name me spelling mistake hai.
  #
  # Current:
  # my_enviroment
  #
  # Recommended:
  # my_environment
  #
  # Production projects me meaningful naming use karna chahiye.
  description = "Environment name for resource tagging"

  # Default Environment
  #
  # Common values:
  # dev
  # test
  # staging
  # prod
  default = "dev"
}

