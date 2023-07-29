
# creating vpc
resource "aws_vpc" "flask_vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true
  

  tags = {
    Name = "flaskapp_vpc"
  }
}

#creating public and private subnet
resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.flask_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "Publicsub"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.flask_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "Publicsub"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.flask_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "Privatesub"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.flask_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "Privatesub"
  }
}

# creating internet gateway
resource "aws_internet_gateway" "public_gw" {
  vpc_id = aws_vpc.flask_vpc.id

  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.flask_vpc.id

  # route {
  #   cidr_block = "0.0.0.0/0"
  #   gateway_id = aws_internet_gateway.flaskapp_gw.id
  # }
  tags = {
    name = "public_route_table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.flask_vpc.id
  tags = {
    name = "private_route_table"
  }
}

resource "aws_route" "public_internet_gw_route" {
  route_table_id         = aws_route_table.public_route_table.id
  gateway_id             = aws_internet_gateway.public_gw.id
  destination_cidr_block = "0.0.0.0/0"

}


resource "aws_route_table_association" "public_1_association" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_2_association" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_1_association" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_2_association" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_eip" "elastic_ip_for_nat_gateway" {
  vpc                       = true
  associate_with_private_ip = "10.0.0.10"
  tags = {
    name = "flaskapp_EIP"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.elastic_ip_for_nat_gateway.id
  subnet_id     = aws_subnet.public_1.id

  tags = {
    Name = "flaskapp_NAT_gw"
  }
  depends_on = [aws_eip.elastic_ip_for_nat_gateway]
}


resource "aws_route" "nat_gw_route" {
  route_table_id         = aws_route_table.private_route_table.id
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
  destination_cidr_block = "0.0.0.0/0"

}

resource "aws_security_group" "flaskapp_sg" {
  name        = "flaskapp_sg"
  description = "sg for ECS cluster"
  vpc_id      = aws_vpc.flask_vpc.id

  ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.flask_vpc.cidr_block]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "flaskapp_sg"
  }
}






