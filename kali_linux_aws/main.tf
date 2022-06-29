resource "aws_key_pair" "public_key" {
  key_name   = "sallam_public"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDZUK/9XllDr9SO1oAf40GXS6m6rKJ+4g4vFR9Ee0EgNlcBNEaowvFU7emMwTpVvB48YDafJ0b3+aaEmcbIa6qX+ypLiu/oJ5HgbhSMHUu3IfZlUlXZmratcAaB+HIxE+1/ASRUlEXlVAZPX93p+CbHrud/8EmYD6T62tQodX5AFnuV0zHxfxKeKTv4mXAfpZWO6nHfZlZ6QrrecCotbzCSjkkLEx+HuUMuYx5XfD341ikQ5zz6vJhe2oY2MASrLf6l7FeH0CrgBjUOFNr8G/psdoBSToNQTVmyjmppmYbE3OkMcPNcTtYCNgFEpW3rfyDx8dVcBAeqRG6R0Kfo+1XapBiK5QE+oaqcVkBgOD18m2f9rx+O5slgxA6KhAFdMhypMVOvjQzYOF2ivdXAVGgZtjV+eDozVgT+KcYs/oTq+fGyQoj3Rd5+MdJjFagVdgsY/t+h7T7oSflpHgTcl1J+VszXvkjVhnLshv4meuk2CEeO9upzqKpYyaErDubUHs9o7u6eHXyW8J4ypWvjLn0asfo+pwp85fn7MP7yXGk9B+McIzf9Yh085c6TrdbV5twrm7Rm61UDG7Nn1Yy0lqVd2wGO7Xqi7DOgfty+Av7P8gL/vODJ4tshOUCsjGNiHuELUlwhC/6h5S1VKqG0wwfRWinXfT+YCD2p1AfNDqvHsQ== sallam@sallam-mac"
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
  ami                         = "ami-0f225368873bb2dd1"
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
  zone_id = "Z07964723PNNJ5KCLHM20"
  name    = "attacker3.cloudteamapp.com"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.kali_linux.public_ip]
}


