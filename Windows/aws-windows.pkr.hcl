packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

data "amazon-ami" "windows_2019" {
  filters = {
    name = "Windows_Server-2019-English-Full-Base-*"
  }
  most_recent = true
  owners      = ["801119661308"] 
  region      = var.region
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }


source "amazon-ebs" "windows-2019" {
  ami_name      = var.ami_name
  communicator  = "winrm"
  instance_type = var.instance_type
  region        = var.region
 
  source_ami     = "${data.amazon-ami.windows_2019.id}"
  user_data_file = "../scripts/SetUpWinRM.ps1"
  winrm_insecure = true
  winrm_use_ssl  = true
  winrm_username = "Administrator"
  tags = var.tags
  aws_polling {
    delay_seconds = 30
    max_attempts  = 240
  }
}

build {
  sources = ["source.amazon-ebs.windows-2019"]
  
  post-processor "manifest" {
  }
}

#####################################################################

variable "region" {
  type    = string
}

variable "instance_type" {
  type    = string
}


variable "tags" {
  type = map(string)
}

variable "ami_name" {
  type = string
  default =  "my-windows-2019-aws-{{timestamp}}"
}