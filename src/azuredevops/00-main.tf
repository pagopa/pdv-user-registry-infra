terraform {
  required_version = ">= 1.1.5"

  ## TODO move this part as external configuration when you bild PROD.
  backend "s3" {
    bucket         = "terraform-backend-4337"
    key            = "uat/devops/tfstate"
    region         = "eu-south-1"
    dynamodb_table = "terraform-lock"
  }

  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "= 0.1.8"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.63.0"
    }

  }
}

provider "aws" {
  region = var.aws_region
}