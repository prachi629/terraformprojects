provider "aws" {
  region = "us-east-1"
  access_key = "*******************"
  secret_key = "*********************************"
}

resource "aws_instance" "first-aws-instance" {
  ami = "ami-***************"
  instance_type = "t2.micro"
  tags = {
      name = "First-instance"
  }
}
