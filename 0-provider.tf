terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

variable "cluster_name" {
  default = "viddem"
}

variable "cluster_version" {
  default = "1.22"
}
