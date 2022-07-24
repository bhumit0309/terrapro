# ------------------  VPC ----------------------------

resource "aws_vpc" "b-project-vpc" {
  cidr_block = var.vpc-cidr-block
}

# ------------------  Subnets in A zone ----------------------

# ---- Public ----

resource "aws_subnet" "subnet-1a" {
  vpc_id     = aws_vpc.b-project-vpc.id
  cidr_block = var.sub-ca-1a-cidr-block
  tags = {
    Name = "public-sub-1a"
  }
  availability_zone       = var.sub-avail-zone-1
  map_public_ip_on_launch = "true"
}

# ---- Private ----

resource "aws_subnet" "subnet-2a" {
  vpc_id     = aws_vpc.b-project-vpc.id
  cidr_block = var.sub-ca-2a-cidr-block
  tags = {
    Name = "private-sub-2a"
  }
  availability_zone = var.sub-avail-zone-1
  ## map_public_ip_on_launch = "true"
}

# ------------------  Subnets in B zone ----------------------

# ---- Public ----


resource "aws_subnet" "subnet-1b" {
  vpc_id     = aws_vpc.b-project-vpc.id
  cidr_block = var.sub-ca-1b-cidr-block
  tags = {
    Name = "public-sub-1b"
  }
  availability_zone       = var.sub-avail-zone-2
  map_public_ip_on_launch = "true"
}

# ---- Private ----

resource "aws_subnet" "subnet-2b" {
  vpc_id     = aws_vpc.b-project-vpc.id
  cidr_block = var.sub-ca-2b-cidr-block
  tags = {
    Name = "private-sub-2b"
  }
  availability_zone = var.sub-avail-zone-2
  ## map_public_ip_on_launch = "true"
}

# ------------------  Internal Gateway ----------------------

resource "aws_internet_gateway" "project-ig" {
  vpc_id = aws_vpc.b-project-vpc.id

  tags = {
    Name = "project-ig"
  }
}

resource "aws_route_table" "public-route" {
    vpc_id = aws_vpc.b-project-vpc.id

  route {
    cidr_block = var.public-cidr-block
    gateway_id = aws_internet_gateway.project-ig.id
  }

  tags = {
    Name = "public_route"
  }
  
}

# ------------------  Security group 1 ----------------------

resource "aws_security_group" "project-security-group" {
  name        = "project-security-group"
  description = "Allow inbound traffic 22/80"
  vpc_id      = aws_vpc.b-project-vpc.id

  ingress {
    description      = "Allow inbound traffic on port 80"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["${var.public-cidr-block}"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "allow SSH access on port 22"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["${var.public-cidr-block}"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["${var.public-cidr-block}"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow-in-traffic"
  }
}

# ------------------  Security group 2 ----------------------

resource "aws_security_group" "lb-security-group" {
  name        = "lb-security-group"
  description = "Allow inbound traffic 80"
  vpc_id      = aws_vpc.b-project-vpc.id

  ingress {
    description      = "Allow inbound traffic on port 80"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["${var.public-cidr-block}"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["${var.public-cidr-block}"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow-in-traffic-80"
  }
}

# -------------------- Instances ----------------------------

# ---------- 1
resource "aws_instance" "wp-instance" {

  ami           = var.ami-wp
  instance_type = var.instance-type
  tags = {
    Name = "wp-instance"
  }
  subnet_id              = aws_subnet.subnet-1a.id
  vpc_security_group_ids = [aws_security_group.project-security-group.id]
  key_name               = var.key-name
}

# ----------- 2
resource "aws_db_instance" "rds-instance" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  #name                 = "mydb"
  username             = "root"
  password             = "password"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}

# ---------- 3
resource "aws_instance" "bs-instance" {

  ami           = var.ami-bs
  instance_type = var.instance-type
  tags = {
    Name = "bs-instance"
  }
  subnet_id              = aws_subnet.subnet-1b.id
  vpc_security_group_ids = [aws_security_group.project-security-group.id]
  key_name               = var.key-name
}

# ---------- 4
resource "aws_instance" "ub-instance" {

  ami           = var.ami-ub
  instance_type = var.instance-type
  tags = {
    Name = "ub-instance"
  }
  subnet_id              = aws_subnet.subnet-2b.id
  vpc_security_group_ids = [aws_security_group.project-security-group.id]
  key_name               = var.key-name
}

# -------------------- NAT GW 1 ----------------------------

resource "aws_eip" "nat-gateway-1-ip" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gateway-1" {
  allocation_id = aws_eip.nat-gateway-1-ip.id
  subnet_id = aws_subnet.subnet-1a.id
  tags = {
    "Name" = "nat-gateway-1"
  }
}

resource "aws_route_table" "rt-1" {
  vpc_id = aws_vpc.b-project-vpc.id
  route {
    cidr_block = var.public-cidr-block
    nat_gateway_id = aws_nat_gateway.nat-gateway-1.id
  }
}

resource "aws_route_table_association" "rta-1" {
  subnet_id = aws_subnet.subnet-1a.id
  route_table_id = aws_route_table.rt-1.id
}

# -------------------- NAT GW 2 ----------------------------

resource "aws_eip" "nat-gateway-2-ip" {
  vpc = true
}

resource "aws_nat_gateway" "nat-gateway-2" {
  allocation_id = aws_eip.nat-gateway-2-ip.id
  subnet_id = aws_subnet.subnet-2a.id
  tags = {
    "Name" = "nat-gateway-2"
  }
}

resource "aws_route_table" "rt-2" {
  vpc_id = aws_vpc.b-project-vpc.id
  route {
    cidr_block = var.public-cidr-block
    nat_gateway_id = aws_nat_gateway.nat-gateway-2.id
  }
}

resource "aws_route_table_association" "rta-2" {
  subnet_id = aws_subnet.subnet-2a.id
  route_table_id = aws_route_table.rt-2.id
} 

# -------------------- Load Balancer ----------------------------

resource "aws_lb" "project-lb" {
  name               = "project-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-security-group.id]
  subnets            = [aws_subnet.subnet-1a.id, aws_subnet.subnet-1b.id]

  tags = {
    Environment = "Production"
  }
}

resource "aws_lb_listener" "lb-listener-80" {
  load_balancer_arn = aws_lb.project-lb.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target-group.arn
  }
}

resource "aws_lb_listener" "lb-listener-22" {
  load_balancer_arn = aws_lb.project-lb.arn
  port              = "22"
  protocol          = "SSH"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target-group.arn
  }
}

# -------------------- Target Group ----------------------------

resource "aws_lb_target_group" "target-group" {
  name        = "target-group"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.b-project-vpc.id
}

resource "aws_lb_target_group_attachment" "target-group-attachment-1" {
  target_group_arn = aws_lb_target_group.target-group.arn
  target_id        = aws_instance.wp-instance.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "target-group-attachment-2" {
  target_group_arn = aws_lb_target_group.target-group.arn
  target_id        = aws_instance.bs-instance.id
  port             = 22
}