provider "aws" {
  region = "eu-west-2"
}

# VPC
resource "aws_vpc" "uat" {
  cidr_block = "10.5.0.0/16"

  tags {
    Name = "uat-george"
  }
}

# application instance
resource "aws_instance" "app" {
  ami = "ami-9af5e9fe"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.public.id}"
  security_groups = ["${aws_security_group.app.id}"]
  user_data = "${data.template_file.init.rendered}"

  tags {
    Name = "app-george"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# database instance
resource "aws_instance" "db" {
  ami = "ami-45fde121"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.private.id}"
  security_groups = ["${aws_security_group.db.id}"]

  tags {
    Name = "db-george"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create a new load balancer
resource "aws_elb" "elb" {
  name               = "alb-george"
  availability_zones = ["eu-west-2a"]
  subnets = ["",""]
  vpc_id = "${aws_vpc.uat.id}"

  # access_logs {
  #   bucket        = "foo"
  #   bucket_prefix = "bar"
  #   interval      = 60
  # }

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  # listener {
  #   instance_port      = 8000
  #   instance_protocol  = "http"
  #   lb_port            = 443
  #   lb_protocol        = "https"
  #   ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
  # }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 10
  }

  instances                   = ["${aws_instance.app.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name = "elb-george"
  }
}

# private subnet for db
resource "aws_subnet" "db" {
  vpc_id = "${aws_vpc.uat.id}"
  cidr_block = "10.5.0.0/24"
  availability_zone = "eu-west-2a"

  tags {
    Name = "db-george"
  }
}

# ~~public~~ private subnet for app 
resource "aws_subnet" "app" {
  vpc_id = "${aws_vpc.uat.id}"
  cidr_block = "10.5.1.0/24"
  availability_zone = "eu-west-2a"
  # map_public_ip_on_launch = true

  tags {
    Name = "app-george"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# public subnet for elb
resource "aws_subnet" "elb" {
  vpc_id = "${aws_vpc.uat.id}"
  cidr_block = "10.5.2.0/24"
  availability_zone = "eu-west-2a"
  map_public_ip_on_launch = true

  tags {
    Name = "elb-george"
  }
}

# Template for initial configuration bash script
data "template_file" "init" {
  template = "${file("templates/init.sh.tpl")}"

  vars {
    db_host_ip = "${aws_instance.db.private_ip}"
  }
}

# security group for the app
resource "aws_security_group" "app" {
  name        = "app-george"
  description = "Security group for the app"
  vpc_id      = "${aws_vpc.uat.id}"

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    security_groups = ["${aws_security_group.elb.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    security_groups = ["${aws_security_group.elb.id}"]
  }

  tags {
    Name = "app-george"
  }
}

# security group for the db
resource "aws_security_group" "db" {
  name        = "db-george"
  description = "Security group for the db"
  vpc_id      = "${aws_vpc.uat.id}"

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    security_groups = ["${aws_security_group.app.id}"]
    # cidr_block = "${aws_subnet.app.cidr_block}"
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "db-george"
  }
}

# security group for the elb
resource "aws_security_group" "elb" {
  name        = "elb-george"
  description = "Security group for the elb"
  vpc_id      = "${aws_vpc.uat.id}"

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

  # egress {
  #   from_port   = 3000
  #   to_port     = 3000
  #   protocol    = "tcp"
  #   # security_groups = ["${aws_security_group.app.id}"]
  #   cidr_block = "${aws_subnet.app.cidr_block}"
  # }

  tags {
    Name = "elb-george"
  }
}

# internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.uat.id}"

  tags {
    Name = "gw-george"
  }
}

# public route table
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.uat.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "public-george"
  }
}

# public route table association
resource "aws_route_table_association" "public" {
  subnet_id = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

# default route table
resource "aws_default_route_table" "default" {
  default_route_table_id = "${aws_vpc.uat.default_route_table_id}"

  tags {
    Name = "default-george"
  }
}

# default route table association
resource "aws_route_table_association" "default" {
  subnet_id = "${aws_subnet.private.id}"
  route_table_id = "${aws_default_route_table.default.id}"
}

# default NaCl
resource "aws_default_network_acl" "default" {
  default_network_acl_id = "${aws_vpc.uat.default_network_acl_id}"

  tags {
    Name = "default-george"
  }
}

# private NaCl
resource "aws_network_acl" "private" {
  vpc_id = "${aws_vpc.uat.id}"
  subnet_ids = ["${aws_subnet.private.id}"]

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 27017
    to_port    = 27017
  }

  ##########################################
  egress {
    protocol   = "tcp"
    rule_no    = 50
    action     = "allow"
    cidr_block = "10.5.1.0/24"
    from_port  = 0
    to_port    = 65535
  }
  ##########################################

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 27017
    to_port    = 27017
  }

  tags {
    Name = "private-george"
  }
}

# public NaCl
resource "aws_network_acl" "public" {
  vpc_id = "${aws_vpc.uat.id}"
  subnet_ids = ["${aws_subnet.public.id}"]

  ingress {
    protocol   = "tcp"
    rule_no    = 300
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 433
    to_port    = 433
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.5.1.0/24"
    from_port  = 27017
    to_port    = 27017
  }

  ##########################################
  ingress {
    protocol   = "tcp"
    rule_no    = 50
    action     = "allow"
    cidr_block = "10.5.0.0/24"
    from_port  = 0
    to_port    = 65535
  }
  ##########################################

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags {
    Name = "public-george"
  }
}

