provider "aws" {
  region = "us-east-1"
  access_key = "*****************"
  secret_key = "****************************"
}

variable "myfirstvar" {
    description = "Hey please enter the value"
  
}
//create a vpc
resource "aws_vpc" "prac-1" {
 cidr_block = "10.0.0.0/16"
 tags={
      Name = "prac1"
  } 
}

//create a subnet
resource "aws_subnet" "prac1-subnet" {
    vpc_id = aws_vpc.prac-1.id
    cidr_block = var.myfirstvar[0].cidr_block
    availability_zone = "us-east-1a"
    tags={
      Name = var.myfirstvar[0].Name
  } 
}

//create a subnet
resource "aws_subnet" "prac2-subnet" {
    vpc_id = aws_vpc.prac-1.id
    cidr_block = var.myfirstvar[1].cidr_block
    availability_zone = "us-east-1a"
    tags={
      Name = var.myfirstvar[0].Name
  } 
}



