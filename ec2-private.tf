resource "aws_iam_role" "ec2_ssm_role" {
  name = "dev-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_role_policy_attachment" "ec2_ssm_policy" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "dev-ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm_role.name
}


resource "aws_security_group" "private_ec2_sg" {
  name        = "dev-private-ec2-sg"
  description = "Security group for private EC2 with SSM only"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "dev-private-ec2-sg"
    Environment = "dev"
  }
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "private_ec2" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_az1.id
  vpc_security_group_ids = [aws_security_group.private_ec2_sg.id]

  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_profile.name

  associate_public_ip_address = false

  tags = {
    Name        = "dev-private-ec2"
    Environment = "dev"
  }
}
