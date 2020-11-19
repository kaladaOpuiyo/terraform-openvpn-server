data "aws_ami" "base_ami" {
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }

  most_recent = true
  owners      = ["137112412989"]
}


