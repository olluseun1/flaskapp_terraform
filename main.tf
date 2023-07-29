terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
#   required_version = ">= 1.2.0"
  backend "s3" {
    bucket = "techbleat-terraform-statefile"
    key    = "flaskapp/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  #profile = "default" # AWS Credentials Profile configured on your local desktop terminal  $HOME/.aws/credentials
  region = "eu-west-1"
}
