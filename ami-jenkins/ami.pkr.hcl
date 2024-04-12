packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

// variable "profile" {
//   type    = string
//   default = "ghactions"
// }

variable "aws_region" {
  type    = string
  default = env("AWS_DEFAULT_REGION")
}

variable "source_ami" {
  type    = string
  default = env("SOURCE_AMI")
}

variable "ssh_username" {
  type    = string
  default = env("SSH_USERNAME")
}

variable "domain" {
  type    = string
  default = env("DOMAIN")
}

source "amazon-ebs" "my-ami" {
  //profile         = "${var.profile}"
  region          = "${var.aws_region}"
  ami_users       = ["529898453043", "590323041104", "514441293612"]
  ami_name        = "csye7125_${formatdate("YYYY_MM_DD_hh_mm_ss", timestamp())}"
  ami_description = "AMI for CSYE 7125"
  // ami_regions = [
  //   "us-east-1",
  // ]

  aws_polling {
    delay_seconds = 120
    max_attempts  = 50
  }


  instance_type = "t2.micro"
  source_ami    = "${var.source_ami}"
  ssh_username  = "${var.ssh_username}"

  //   launch_block_device_mappings {
  //     delete_on_termination = true
  //     device_name           = "/dev/sda1"
  //     volume_size           = 8
  //     volume_type           = "gp2"
  //   }
}

build {
  sources = ["source.amazon-ebs.my-ami"]

  provisioner "shell" {
    environment_vars = [
      "DOMAIN=${var.domain}"
    ]
    script = "script.sh"

  }

  provisioner "file" {
    source      = "./seedJob.groovy"
    destination = "/home/ubuntu/seedJob.groovy"
  }

  provisioner "file" {
    source      = "./casc.yaml"
    destination = "/home/ubuntu/casc.yaml"
  }

}