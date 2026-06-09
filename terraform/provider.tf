
# ==================================================
# Local Variables
# ==================================================

# Locals ka use reusable values store karne ke liye hota hai.
#
# Agar koi value multiple places par use ho rahi ho,
# to usse hardcode karne ki jagah locals me define karte hain.
#
# Benefits:
# ✅ Code Clean Rehta Hai
# ✅ Reusability Badh Jaati Hai
# ✅ Maintenance Easy Ho Jaati Hai
# ✅ Ek Jagah Change Karne Se Pura Project Update Ho Jata Hai

locals {

  # ==================================================
  # AWS Region
  # ==================================================

  # Infrastructure kis AWS region me create hoga.
  #
  # eu-west-1 = Ireland Region
  #
  # Agar region change karna ho to sirf yahan change karna padega.
  region = "eu-west-1"


  # ==================================================
  # EKS Cluster Name
  # ==================================================

  # Kubernetes Cluster ka naam.
  #
  # Ye naam multiple resources me use ho sakta hai.
  # Example:
  # - EKS Cluster
  # - Tags
  # - Security Groups
  # - Node Groups
  name = "tws-eks-cluster"


  # ==================================================
  # VPC CIDR Block
  # ==================================================

  # Ye poore VPC ka IP Address Range hai.
  #
  # CIDR:
  # 10.0.0.0/16
  #
  # Total Available IPs:
  # ~65,536
  #
  # Isi range ke andar saare subnets create honge.
  vpc_cidr = "10.0.0.0/16"


  # ==================================================
  # Availability Zones (AZs)
  # ==================================================

  # High Availability ke liye multiple Availability Zones use kar rahe hain.
  #
  # Agar ek AZ fail ho jaye to dusri AZ services ko alive rakhegi.
  azs = [
    "eu-west-1a",
    "eu-west-1b"
  ]


  # ==================================================
  # Public Subnets
  # ==================================================

  # Public Subnets internet accessible hoti hain.
  #
  # Typical Usage:
  # - Load Balancers
  # - Bastion Hosts
  # - Public Services
  #
  # Internet Gateway ke through internet access milta hai.
  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]


  # ==================================================
  # Private Subnets
  # ==================================================

  # Private Subnets directly internet se accessible nahi hoti.
  #
  # Typical Usage:
  # - Application Servers
  # - Databases
  # - Backend Services
  #
  # Security ke liye sensitive workloads yahan deploy kiye jaate hain.
  private_subnets = [
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]


  # ==================================================
  # Intra Subnets
  # ==================================================

  # Intra Subnets internal communication ke liye use hoti hain.
  #
  # AWS EKS me aksar Control Plane ke liye use ki jaati hain.
  #
  # Ye internet accessible nahi hoti.
  intra_subnets = [
    "10.0.5.0/24",
    "10.0.6.0/24"
  ]


  # ==================================================
  # Common Tags
  # ==================================================

  # Tags AWS resources ko identify karne ke liye use hote hain.
  #
  # Benefits:
  # - Cost Tracking
  # - Resource Identification
  # - Automation
  # - Governance
  tags = {

    # Cluster Name ko tag ke roop me store kar rahe hain.
    example = local.name
  }

}


# ==================================================
# AWS Provider Configuration
# ==================================================

# Provider Terraform ko batata hai
# ki kis cloud platform ke saath communicate karna hai.

provider "aws" {

  # AWS Region local variable se aa raha hai.
  #
  # Terraform ke saare AWS resources
  # isi region me create honge.
  region = local.region

}
