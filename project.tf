provider "aws" {
  region = "us-east-1"
  access_key = "****************************"
  secret_key = "************************************M"
}
//create a vpc
resource "aws_vpc" "prac-1" {
 cidr_block = "10.0.0.0/16"
 tags={
      Name = "prac1"
  } 
}
//create a internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prac-1.id
}
//route table
resource "aws_route_table" "routetable1" {
  vpc_id = aws_vpc.prac-1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "route"
  }
}
//create a subnet
resource "aws_subnet" "prac1-subnet" {
    vpc_id = aws_vpc.prac-1.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
}

//assosiate route table with subnet
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.prac1-subnet.id
  route_table_id = aws_route_table.routetable1.id
}

//security group allow
resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.prac-1.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
 ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
   ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_WEB"
  }
}

// create a network interface
resource "aws_network_interface" "web-server" {
  subnet_id       = aws_subnet.prac1-subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web.id]
}
//eip
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server.id
  associate_with_private_ip = "10.0.1.50"
  depends_on =[aws_internet_gateway.gw]
}

//create instance
resource "aws_instance" "prac1_instance" {
    ami = "ami-09d56f8956ab235b3"
    instance_type= "t2.micro"
    availability_zone = "us-east-1a"
    key_name = "main-key"

    network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.web-server.id
    }

    user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemct1 start apache2
                sudo bash -c 'echo your very first web server > /var/www/html/index.html'
                EOF

    tags ={
        name = "web-server"
    }
}


