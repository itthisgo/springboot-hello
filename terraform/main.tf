provider "aws" {
  region = "ap-northeast-2"  # 서울 리전
}

resource "aws_security_group" "my_sg" {
  name        = "springboot-hello-sg"
  description = "Allow inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "my_server" {
  ami                  = "ami-0077297a838d6761d"  # 최신 Ubuntu AMI 사용 (변경 필요)
  instance_type        = "t2.micro"
  key_name            = var.key_name
  security_groups      = [aws_security_group.my_sg.name]
  associate_public_ip_address = true  # 퍼블릭 IP 할당

  tags = {
    Name = "springboot-hello-ec2"
  }
}

output "ec2_public_ip" {
  value = aws_instance.my_server.public_ip
}
