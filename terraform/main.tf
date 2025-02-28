provider "aws" {
  region = "ap-northeast-2"  # 서울 리전
}

# 기본 VPC 가져오기
data "aws_vpc" "default" {
  id = "vpc-0a26da92d28ec58b9"
}

# 기본 VPC 내에서 특정 가용 영역(AZ)의 서브넷 가져오기
data "aws_subnet" "default" {
  filter {
    name   = "vpc-id"
    values = ["vpc-0a26da92d28ec58b9"]
  }

  filter {
    name   = "availability-zone"
    values = ["ap-northeast-2a"]  # 가용 영역 지정
  }
}

# 기존 보안 그룹이 있는지 확인
data "aws_security_groups" "existing_sg" {
  filter {
    name   = "group-name"
    values = ["springboot-hello-sg"]
  }
}

# 보안 그룹이 없으면 새로 생성
resource "aws_security_group" "my_sg" {
  count       = length(data.aws_security_groups.existing_sg.ids) > 0 ? 0 : 1
  name        = "springboot-hello-sg"
  description = "Allow inbound traffic"
  vpc_id      = data.aws_vpc.default.id  # 기본 VPC에 배치

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 인스턴스 생성 (보안 그룹 동적 적용)
resource "aws_instance" "my_server" {
  ami                    = "ami-0077297a838d6761d"  # 최신 Ubuntu AMI
  instance_type          = "t2.micro"
  key_name               = var.key_name
  subnet_id              = data.aws_subnet.default.id  # 기본 VPC의 서브넷 사용
  vpc_security_group_ids = length(data.aws_security_groups.existing_sg.ids) > 0 ? [data.aws_security_groups.existing_sg.ids[0]] : [aws_security_group.my_sg[0].id]
  associate_public_ip_address = true  # 퍼블릭 IP 할당

  tags = {
    Name = "springboot-hello-ec2"
  }
}

provisioner "remote-exec" {
    inline = [
      "mkdir -p ~/.ssh",
      "echo '${var.ec2_ssh_key}' >> ~/.ssh/authorized_keys",
      "chmod 600 ~/.ssh/authorized_keys"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"  # Amazon Linux는 "ec2-user"
      private_key = file(var.ec2_ssh_key_file)  # 🔥 GitHub Actions에서 SSH 키를 전달해야 함
      host        = self.public_ip
    }
  }
}

# 생성된 EC2의 Public IP 출력
output "ec2_public_ip" {
  value = aws_instance.my_server.public_ip
}
