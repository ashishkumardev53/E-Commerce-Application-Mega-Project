# ==================================================
# Ubuntu AMI (Amazon Machine Image) Fetch Karna
# ==================================================

# Data source ka use existing AWS resources ki information lene ke liye hota hai.
# Yahan hum latest Ubuntu 24.04 AMI automatically fetch kar rahe hain.
# Isse hume manually AMI ID update nahi karni padti.

data "aws_ami" "os_image" {

  # Canonical (Ubuntu Official Publisher) ka AWS Account ID.
  # Isse ensure hota hai ki official Ubuntu image hi use ho.
  owners = ["099720109477"]

  # Sabse latest available AMI select karega.
  most_recent = true

  # Sirf available state wali images consider karo.
  filter {
    name   = "state"
    values = ["available"]
  }

  # Ubuntu 24.04 AMD64 architecture wali image filter kar rahe hain.
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/*24.04-amd64*"]
  }
}


# ==================================================
# SSH Key Pair Create Karna
# ==================================================

# EC2 instance me SSH login karne ke liye key pair create kar rahe hain.
# Public key AWS me store hogi aur private key hamare paas rahegi.

resource "aws_key_pair" "deployer" {

  # AWS me key pair ka naam.
  key_name = "terra-automate-key"

  # Local machine se public key read kar rahe hain.
  public_key = file("terra-key.pub")
}


# ==================================================
# Default VPC Use Karna
# ==================================================

# AWS account me jo default VPC already bani hoti hai
# usko Terraform ke through access kar rahe hain.

resource "aws_default_vpc" "default" {

}


# ==================================================
# Security Group Create Karna
# ==================================================

# Security Group EC2 instance ka firewall hota hai.
# Ye decide karta hai kaunsa traffic allow ya block hoga.

resource "aws_security_group" "allow_user_to_connect" {

  name        = "allow TLS"
  description = "Allow user to connect"

  # Security Group ko default VPC ke andar create kar rahe hain.
  vpc_id = aws_default_vpc.default.id


  # ------------------------------------
  # SSH Access (Port 22)
  # ------------------------------------
  # Is port ke through hum server me SSH login karenge.

  ingress {
    description = "port 22 allow"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    # 0.0.0.0/0 ka matlab duniya me kahin se bhi access.
    # Production me apna public IP dena zyada secure hota hai.
    cidr_blocks = ["0.0.0.0/0"]
  }


  # ------------------------------------
  # Outbound Traffic
  # ------------------------------------
  # Server ko internet access dene ke liye.
  # Updates download, packages install aur APIs call karne ke liye zaruri.

  egress {
    description = "allow all outgoing traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }


  # ------------------------------------
  # HTTP Access (Port 80)
  # ------------------------------------
  # Normal websites ke liye.

  ingress {
    description = "port 80 allow"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # ------------------------------------
  # HTTPS Access (Port 443)
  # ------------------------------------
  # Secure SSL/TLS traffic ke liye.

  ingress {
    description = "port 443 allow"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # ------------------------------------
  # Jenkins Access (Port 8080)
  # ------------------------------------
  # Jenkins UI access karne ke liye.

  ingress {
    description = "port 8080 allow"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "mysecurity"
  }
}


# ==================================================
# EC2 Instance Create Karna
# ==================================================

# Ye resource actual virtual machine launch karega.

resource "aws_instance" "testinstance" {

  # Upar fetch ki gayi latest Ubuntu AMI use kar rahe hain.
  ami = data.aws_ami.os_image.id

  # Instance size variable se aa raha hai.
  # Example: t2.micro, t3.small, t3.medium etc.
  instance_type = var.instance_type

  # SSH login ke liye key pair attach kar rahe hain.
  key_name = aws_key_pair.deployer.key_name

  # Security Group attach kar rahe hain.
  security_groups = [
    aws_security_group.allow_user_to_connect.name
  ]

  # Instance start hote hi ye script automatically execute hogi.
  # Iska use Jenkins, Docker ya required tools install karne ke liye hota hai.
  user_data = file("${path.module}/install_tools.sh")

  tags = {
    Name = "Jenkins-Automate"
  }

  # Root EBS Volume Configuration
  # Default disk ko customize kar rahe hain.

  root_block_device {

    # Disk size 20 GB
    volume_size = 20

    # GP3 latest generation SSD storage hai.
    # Better performance aur lower cost provide karti hai.
    volume_type = "gp3"
  }
}
