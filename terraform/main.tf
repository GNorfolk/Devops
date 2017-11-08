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

# application inastance
resource "aws_instance" "app" {
	ami = "ami-82ffe3e6"
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

# private subnet for db
resource "aws_subnet" "private" {
	vpc_id = "${aws_vpc.uat.id}"
	cidr_block = "10.5.0.0/24"

	tags {
		Name = "private-george"
	}
}

# public subnet for app 
resource "aws_subnet" "public" {
	vpc_id = "${aws_vpc.uat.id}"
	cidr_block = "10.5.1.0/24"
	map_public_ip_on_launch = true

	tags {
		Name = "public-george"
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
		to_port     = 65535
		protocol    = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
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
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    # cidr_blocks = ["${aws_security_group.app.id}"]
    security_groups = ["${aws_security_group.app.id}"]
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
    from_port  = 5432
    to_port    = 5432
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 5432
    to_port    = 5432
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
    from_port  = 5432
    to_port    = 5432
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  # egress {
  #   protocol   = "tcp"
  #   rule_no    = 300
  #   action     = "allow"
  #   cidr_block = "10.5.1.0/24"
  #   from_port  = 5432
  #   to_port    = 5432
  # }

  # egress {
  #   protocol   = "tcp"
  #   rule_no    = 200
  #   action     = "allow"
  #   cidr_block = "0.0.0.0/0"
  #   from_port  = 443
  #   to_port    = 443
  # }

  # egress {
  #   protocol   = "tcp"
  #   rule_no    = 100
  #   action     = "allow"
  #   cidr_block = "0.0.0.0/0"
  #   from_port  = 80
  #   to_port    = 80
  # }

  tags {
    Name = "public-george"
  }
}