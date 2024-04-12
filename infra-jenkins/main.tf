resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block

  tags = {
    Name = "${var.profile}-VPC"
  }
}

data "aws_availability_zones" "all" {
  state = "available"
}

# Creating public subnet
resource "aws_subnet" "public_subnet" {
  count             = var.public_subnet
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 1, count.index)
  availability_zone = element(data.aws_availability_zones.all.names, count.index % length(data.aws_availability_zones.all.names))

  tags = {
    Name = "Public subnet ${count.index + 1} - ${var.profile}-VPC"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Internet gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "Public route table"
  }
}


resource "aws_route_table_association" "aws_public_route_table_association" {
  count          = var.public_subnet
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}


resource "aws_security_group" "application" {
  name        = "application"
  description = "Allow TLS inbound/outbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Access to CA"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH into Instance"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Access to Internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

data "aws_ami" "amzLinux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["csye7125*"]
  }
}

resource "aws_key_pair" "ec2keypair" {
  key_name   = "ec2.pub"
  public_key = file("~/.ssh/ec2.pub")
}

resource "aws_instance" "webapp" {
  ami                         = data.aws_ami.amzLinux.id #"ami-0dfcb1ef8550277af"
  instance_type               = "t2.small"
  associate_public_ip_address = false
  key_name                    = aws_key_pair.ec2keypair.key_name
  security_groups = [
    aws_security_group.application.id
  ]

  subnet_id = aws_subnet.public_subnet[0].id
  tags = {
    "Name" = "Jenkins Server"
  }

  tenancy = "default"

  depends_on = [aws_route53_record.new_record]

  vpc_security_group_ids = [
    aws_security_group.application.id
  ]

  lifecycle {
    prevent_destroy = false
  }

  root_block_device {
    delete_on_termination = true
    volume_size           = 30
    volume_type           = "gp2"
  }
  user_data = <<EOF
#!/bin/bash
sudo cp /home/ubuntu/seedJob.groovy /var/lib/jenkins
sudo cp /home/ubuntu/casc.yaml /var/lib/jenkins
sudo docker buildx create --name webapplication
sudo systemctl restart jenkins
sudo docker buildx use webapplication
sudo docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
EOF
}

data "aws_eip" "elasticip" {
  tags = {
    Name = "Jenkins"
  }
}

resource "aws_eip_association" "eip_association" {
  instance_id   = aws_instance.webapp.id
  allocation_id = data.aws_eip.elasticip.id
}

data "aws_route53_zone" "selected" {
  name = var.domain
}

resource "aws_route53_record" "new_record" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = data.aws_route53_zone.selected.name
  type    = "A"
  ttl     = 60
  records = [data.aws_eip.elasticip.public_ip]
}