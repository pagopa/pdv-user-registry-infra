terraform {
  required_version = ">= 1.0.0"

  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "> 3.63.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  project = format("%s-%s", var.app_name, var.env_short)
}