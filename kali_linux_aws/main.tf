resource "aws_key_pair" "public_key" {
  key_name   = "public"
  public_key = ""
}

data "template_file" "user_data" {
  template = file("../kali_linux_aws/payload.sh")
}

resource "aws_default_subnet" "default" {
    availability_zone = var.availability_zone
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_security_group" "kali_security_group" {
  name        = "allow_kali_student3"
  description = "Allow ssh and rdp"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "rdp"
    from_port        = 3389
    to_port          = 3389
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
    Name = "kali_security_group"
  }
}

resource "aws_instance" "kali_linux" {
  ami                         = "ami-xxxx"
  instance_type               = var.instance_type
  availability_zone           = var.availability_zone
  associate_public_ip_address = true
  key_name                    = aws_key_pair.public_key.key_name
  user_data                   = data.template_file.user_data.rendered
  subnet_id                   = var.subnet_id == null ? aws_default_subnet.default.id : var.subnet_id
  vpc_security_group_ids      = [aws_security_group.kali_security_group.id]
  

  root_block_device {
    volume_size = var.volume_size
  }
  tags = {
    Name = "Student3"
  }
}


resource "aws_route53_record" "cloudteam" {
  zone_id = "zoneid"
  name    = "attackerx.example.com"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.kali_linux.public_ip]
}


