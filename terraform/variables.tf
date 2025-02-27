variable "key_name" {
  description = "AWS EC2 SSH Key Pair"
  type        = string
  default     = "myserver"  # 기존 AWS Key Pair 이름 사용
}
