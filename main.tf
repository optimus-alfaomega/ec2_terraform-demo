terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.59.0"
    }
  }
}


##########################
###### Provider Config block 

provider "aws" {
 region = "us-east-1"
 access_key= ""
 secret_key= ""

}

#############################3

resource "aws_key_pair" "deployer" {
    key_name   = "deployer-key"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBXxCs/yBvt555RHJAmfzROa47sy1NV33oJGi7Tc9GsfE8RRkfTh2FpyKQII+kYg4N+YQdga6JYWbNCcRZXvnxL4FIpa6fZiyUsY2+khu9H+6fHrd6sR+5fRmWhJY3/mtIYqYDLyUKsSXsVhVLkWdG5dLcTorsxRGmDKfojcJivqPTTWrzN/zDAN3smpTJpxevnMoue03DpR70myfZOd5dfIWiroviHbAsm+M23tDB7eSV8Kwke5yFjYCXScEqxjCM4EjlAKQrQDMYg5Qy+kdLhlIJrCh/N6W1ak1O5QwHFVciQbVw6692U0DWefEmD1rWeiZJHBklbJROnFveVZMD3j7ChjJ7hnYFhTGo6p/ff4n+klOyWWrMOxi4tTDU/ASTxDwOw8f+xM+EBxrj2bm6VtlSqrl8k0dK87ITkd24G8LzaFGBrD9FWRl9kogd2a7v5yKKlF7bx/z89QQ7ZKX4YWfXu8XtjaCkSyuG2tFTS7J3C2MqP4LZN9ywD2TP3Wc= 00793@DESKTOP-COJ1IBC"
}

data "template_file" "user_data" {

  template = file("./userdata.yaml")
 
}

data "aws_vpc" "main" {
 id = "vpc-e5b4dc98"
}


resource "aws_security_group" "sg_my_server" {
  name        = "sg_my_server"
  description = "my_security_group"
  vpc_id      = "${data.aws_vpc.main.id}"

  ingress  {
            description      = "HTTP"
            from_port        = 80
            to_port          = 80
            protocol         = "tcp"
            cidr_blocks      = ["0.0.0.0/0"]
            ipv6_cidr_blocks = []
            }
   ingress  {
            description      = "SSH"
            from_port        = 22
            to_port          = 22
            protocol         = "tcp"
            cidr_blocks      = ["0.0.0.0/0"]
            ipv6_cidr_blocks = []
            }
  
  egress {
            from_port        = 0
            to_port          = 0
            protocol         = "-1"
            cidr_blocks      = ["0.0.0.0/0"]
            ipv6_cidr_blocks = ["::/0"]
         }

}

# Find the latest available AMI that is tagged with Component = web


########################
resource "aws_instance" "my_server"{
  ami = "ami-0ed9277fb7eb570c9"
  instance_type= "t2.micro"
  key_name = "${aws_key_pair.deployer.key_name}"
  vpc_security_group_ids = [aws_security_group.sg_my_server.id]
  user_data = data.template_file.user_data.template
  tags = {
     Name = "MyServer"
     description = "Servidor creado desde terrraform"
     otro = "por eliminar mediante comando"     
  } 

}





output  "public_ip" {
  value       = aws_instance.my_server.public_ip
  description = "description"
}
