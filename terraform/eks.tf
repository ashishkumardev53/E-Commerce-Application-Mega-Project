
# ==================================================
# Amazon EKS (Elastic Kubernetes Service) Cluster
# ==================================================

# Yahan hum Terraform ke official AWS EKS module ka use kar rahe hain.
# EKS module bahut saare AWS resources (Cluster, Node Groups, IAM Roles etc.)
# automatically create kar deta hai.
# Agar manually create karein to bahut zyada code likhna padta.

module "eks" {

  # Terraform Registry se EKS module download hoga.
  source = "terraform-aws-modules/eks/aws"

  # Specific module version lock kar rahe hain.
  # Isse future updates ki wajah se configuration break nahi hogi.
  version = "19.15.1"


  # ==================================================
  # EKS Cluster Configuration
  # ==================================================

  # Kubernetes Cluster ka naam.
  # Ye local variable se aa raha hai.
  cluster_name = local.name

  # Kubernetes API Server ko internet se accessible bana raha hai.
  # Iske baad local machine se kubectl commands chala sakte ho.
  cluster_endpoint_public_access = true


  # ==================================================
  # EKS Cluster Addons
  # ==================================================

  # Addons Kubernetes ke built-in components hote hain.
  # Ye cluster ke proper functioning ke liye zaruri hote hain.

  cluster_addons = {

    # ------------------------------------
    # CoreDNS
    # ------------------------------------
    # Cluster ke andar DNS service provide karta hai.
    # Pods aur Services ek dusre ko naam se access kar sakte hain.
    coredns = {
      most_recent = true
    }

    # ------------------------------------
    # Kube Proxy
    # ------------------------------------
    # Network traffic routing handle karta hai.
    # Service aur Pod ke beech communication manage karta hai.
    kube-proxy = {
      most_recent = true
    }

    # ------------------------------------
    # VPC CNI Plugin
    # ------------------------------------
    # Pods ko AWS VPC ke IP addresses assign karta hai.
    # Kubernetes networking aur AWS networking ko connect karta hai.
    vpc-cni = {
      most_recent = true
    }
  }


  # ==================================================
  # Network Configuration
  # ==================================================

  # Kis VPC ke andar cluster create hoga.
  vpc_id = module.vpc.vpc_id

  # Worker Nodes in subnets me launch honge.
  subnet_ids = module.vpc.public_subnets

  # Control Plane ke liye dedicated internal subnets.
  # Security ke liye recommended setup hai.
  control_plane_subnet_ids = module.vpc.intra_subnets


  # ==================================================
  # Managed Node Group Defaults
  # ==================================================

  # Jo settings sabhi Node Groups par apply hongi.

  eks_managed_node_group_defaults = {

    # Default EC2 instance type.
    instance_types = ["t2.large"]

    # Cluster ka primary security group nodes ke saath attach hoga.
    attach_cluster_primary_security_group = true
  }


  # ==================================================
  # EKS Managed Node Groups
  # ==================================================

  # Node Group worker machines ka group hota hai.
  # Actual application Pods inhi machines par run karte hain.

  eks_managed_node_groups = {

    # Node Group ka naam
    tws-demo-ng = {

      # Minimum kitne nodes hamesha running rahenge.
      min_size = 2

      # Maximum nodes autoscaling ke baad kitne ho sakte hain.
      max_size = 3

      # Initial node count.
      desired_size = 2


      # Worker nodes ka EC2 instance type.
      instance_types = ["t2.large"]


      # Spot Instances use kar rahe hain.
      # Spot instances AWS ke unused servers hote hain.
      # Cost kam hoti hai lekin AWS kabhi bhi reclaim kar sakta hai.
      capacity_type = "SPOT"


      # Har node ke root disk ka size.
      # By default disk chhoti hoti hai,
      # isliye yahan 35 GB set kiya gaya hai.
      disk_size = 35


      # AWS launch template create na karke
      # direct node configuration use kar rahe hain.
      # Disk size properly apply karne ke liye important hai.
      use_custom_launch_template = false


      # Resource Tags
      tags = {

        # Node Group ka naam
        Name = "tws-demo-ng"

        # Environment Type
        Environment = "dev"

        # Custom Business/Application Tag
        ExtraTag = "e-commerce-app"
      }
    }
  }


  # Common tags jo cluster ke resources par apply hongi.
  tags = local.tags
}


# ==================================================
# Running Worker Nodes Fetch Karna
# ==================================================

# Ye Data Source existing EC2 instances ki information fetch karta hai.

data "aws_instances" "eks_nodes" {

  # Sirf us cluster ke nodes fetch karo
  # jiska cluster name current EKS cluster se match karta ho.
  instance_tags = {
    "eks:cluster-name" = module.eks.cluster_name
  }


  # Sirf running state wali EC2 instances return karo.
  filter {
    name   = "instance-state-name"
    values = ["running"]
  }


  # Pehle EKS cluster create hoga,
  # uske baad hi worker nodes search kiye jayenge.
  depends_on = [module.eks]
}

