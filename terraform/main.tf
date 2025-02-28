provider "aws" {
  region = "ap-northeast-2"  # 서울 리전
}

# 기존 보안 그룹이 있는지 확인
data "aws_security_group" "existing_sg" {
  filter {
    name   = "group-name"
    values = ["springboot-hello-sg"]
  }
}

# 없으면 새로 생성
resource "aws_security_group" "my_sg" {
  count       = length(data.aws_security_group.existing_sg.id) > 0 ? 0 : 1
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

# EC2 인스턴스 생성 (보안 그룹 동적 적용)
resource "aws_instance" "my_server" {
  ami                    = "ami-0077297a838d6761d"  # 최신 Ubuntu AMI
  instance_type          = "t2.micro"
  key_name               = var.key_name
  security_group_ids     = length(data.aws_security_group.existing_sg.id) > 0 ? [data.aws_security_group.existing_sg.id] : [aws_security_group.my_sg[0].id]
  associate_public_ip_address = true  # 퍼블릭 IP 할당

  tags = {
    Name = "springboot-hello-ec2"
  }
}

# 생성된 EC2의 Public IP 출력
output "ec2_public_ip" {
  value = aws_instance.my_server.public_ip
}
