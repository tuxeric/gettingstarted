provider "aws" {
  region = "eu-central-1"
}

terraform {
  backend "s3" {
    bucket = "mytfstates"
    key = "up_and_run_chapter3/terraform.tfstate"
    region = "eu-central-1"
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "mytfstates"

  versioning {
    enabled = "true"
  }

  lifecycle {
    prevent_destroy = "true"
  }
}
