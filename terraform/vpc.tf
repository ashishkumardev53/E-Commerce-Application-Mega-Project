
# ==================================================
# AWS VPC (Virtual Private Cloud)
# ==================================================

# VPC AWS ke andar ek private network hota hai.
#
# Iske andar hum:
# - EC2 Instances
# - EKS Cluster
# - Databases
# - Load Balancers
#
# Jaise resources deploy karte hain.
#
# Simple language me:
#
# AWS Account
#      ↓
# VPC
#      ↓
# Subnets
#      ↓
# Resources
#
# Yahan hum Terraform ke official VPC module ka use kar rahe hain
# taki manually networking resources create na karne pade.

module "vpc" {

  # Terraform Registry se AWS VPC module download hoga.
  source = "terraform-aws-modules/vpc/aws"

  # Module version lock kar rahe hain.
  # Future updates ki wajah se code break nahi hoga.
  version = "~> 4.0"


  # ==================================================
  # Basic VPC Configuration
  # ==================================================

  # VPC ka naam.
  # Ye local variable se aa raha hai.
  name = local.name

  # VPC ka CIDR Range.
  #
  # Is IP range ke andar saare subnets create honge.
  #
  # 10.0.0.0/16
  # ≈ 65,536 IP Addresses
  cidr = local.vpc_cidr

  # Availability Zones
  #
  # Resources multiple AZs me deploy honge.
  # Isse High Availability milti hai.
  azs = local.azs

  # Public Subnets
  #
  # Internet accessible resources ke liye.
  #
  # Examples:
  # - Load Balancers
  # - Bastion Hosts
  # - Public EC2 Servers
  public_subnets = local.public_subnets

  # Private Subnets
  #
  # Internal application workloads ke liye.
  #
  # Examples:
  # - Backend Applications
  # - Databases
  # - Internal APIs
  private_subnets = local.private_subnets

  # Intra Subnets
  #
  # Purely internal communication ke liye.
  #
  # AWS EKS me aksar Control Plane networking ke liye use hoti hain.
  intra_subnets = local.intra_subnets


  # ==================================================
  # NAT Gateway
  # ==================================================

  # NAT Gateway enable kar rahe hain.
  #
  # Private Subnets directly internet accessible nahi hoti.
  #
  # Lekin kabhi-kabhi private resources ko:
  # - Software Updates
  # - Package Downloads
  # - Docker Images Pull
  #
  # Karne ke liye internet access chahiye hota hai.
  #
  # NAT Gateway ye allow karta hai.
  #
  # Internet → Private Subnet Access ❌
  # Private Subnet → Internet Access ✅
  enable_nat_gateway = true


  # ==================================================
  # Public Subnet Tags
  # ==================================================

  # Ye tags AWS Load Balancer Controller
  # aur Kubernetes ko batate hain ki
  # ye public subnets hain.
  #
  # Jab Kubernetes LoadBalancer Service create karega,
  # AWS ELB in public subnets me create hoga.

  public_subnet_tags = {

    # External Load Balancer ke liye.
    "kubernetes.io/role/elb" = 1
  }


  # ==================================================
  # Private Subnet Tags
  # ==================================================

  # Ye tags Kubernetes ko batate hain ki
  # ye private/internal subnets hain.
  #
  # Internal Load Balancers yahan create honge.

  private_subnet_tags = {

    # Internal Load Balancer ke liye.
    "kubernetes.io/role/internal-elb" = 1
  }


  # ==================================================
  # Auto Public IP Assignment
  # ==================================================

  # Public subnet me jo bhi EC2 launch hogi,
  # usko automatically Public IP mil jayega.
  #
  # Agar ye false ho:
  #
  # EC2 Launch
  #      ↓
  # No Public IP
  #      ↓
  # SSH Access Nahi
  #
  # Isliye public workloads ke liye useful setting hai.
  map_public_ip_on_launch = true

}

