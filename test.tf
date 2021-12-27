terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.70.0"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "vinod"
  region  = "ap-south-1"
}

resource "aws_instance" "ec2-linux" {
  ami             = "ami-052cef05d01020f1d"
  instance_type   = "t2.micro"
  security_groups = ["sg-0154ec0ae01ecddcd"]
  subnet_id       = "subnet-e7f8baab"

  user_data = <<-EOF
                #! /bin/bash
                sudo  yum install httpd -y
                sudo systemctl start httpd
                sudo systemctl enable httpd.service
                echo -e "<html><head><title>vinod</title></head>\n<body> <h1> VINOD </h1> </body></html>" > /var/www/html/index.html
                sudo systemctl restart httpd.service
            EOF             

  tags = {
    Name = "vinodlinux"
  }

}

resource "aws_ebs_volume" "ec2-vol" {
  availability_zone = "ap-south-1b"
  size              = 7
  tags = {
    Name = "ebs-linux-attach"
  }
}

resource "aws_volume_attachment" "ec2-ebs-atc" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.ec2-vol.id
  instance_id = aws_instance.ec2-linux.id
}
