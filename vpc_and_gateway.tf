data "aws_availability_zones" "azs" {

}

##############
 # Create VPC
#############

resource "aws_vpc" "wordpress_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${var.stack}-vpc"
  }
}

###########################
 # Create Internet Gateway
##########################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.wordpress_vpc.id

  tags = {
    Name = "${var.stack}-igw"
  }
}

##############
 # Create NAT
#############

resource "aws_nat_gateway" "nat" {
  subnet_id     = aws_subnet.public1.id
  allocation_id = aws_eip.eip.id

  tags = {
    Name = "${var.stack}-nat"
  }
}

#####################
 # Create Elastic IP
#####################

resource "aws_eip" "eip" {

  tags = {
    Name = "${var.stack}-nat-ip"
  }
}

############################
 # Route Tables
############################

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.wordpress_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${var.stack}-private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.wordpress_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.stack}-public"
  }
}

resource "aws_route_table_association" "private1" {
  route_table_id = aws_route_table.private.id

  subnet_id = aws_subnet.private1.id
}

resource "aws_route_table_association" "private2" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private2.id
}

resource "aws_route_table_association" "private3" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private3.id
}

resource "aws_route_table_association" "public1" {
  route_table_id = aws_route_table.public.id

  subnet_id = aws_subnet.public1.id
}

resource "aws_route_table_association" "public2" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public2.id
}

##################
 # Public Subnets
##################

resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.wordpress_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = data.aws_availability_zones.azs.names[0]

  tags = {
    Name = "${var.stack}-public-1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.wordpress_vpc.id
  cidr_block = "10.0.1.0/24"

  availability_zone = data.aws_availability_zones.azs.names[1]

  tags = {
    Name = "${var.stack}-public-2"
  }
}

##################
 # Private Subnets
##################

resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.wordpress_vpc.id
  cidr_block = "10.0.100.0/24"

  availability_zone = data.aws_availability_zones.azs.names[0]

  tags = {
    Name = "${var.stack}-private-1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.wordpress_vpc.id
  cidr_block = "10.0.101.0/24"

  availability_zone = data.aws_availability_zones.azs.names[1]

  tags = {
    Name = "${var.stack}-private-2"
  }
}

resource "aws_subnet" "private3" {
  vpc_id            = aws_vpc.wordpress_vpc.id
  cidr_block        = "10.0.102.0/24"
  availability_zone = data.aws_availability_zones.azs.names[2]

  tags = {
    Name = "${var.stack}-private-3"
  }
}

#######################
 # Subnets Group for DB 
#######################

resource "aws_db_subnet_group" "wordpress_db_subnets_group" {
  name       = "${var.stack}-subngroup"
  subnet_ids = [aws_subnet.db_subnet1.id, aws_subnet.db_subnet2.id, aws_subnet.db_subnet3.id]

  tags = {
    Name = "${var.stack}-subnetGroup"
  }
}

resource "aws_subnet" "db_subnet1" {
  vpc_id     = aws_vpc.wordpress_vpc.id
  cidr_block = "10.0.200.0/24"

  availability_zone = data.aws_availability_zones.azs.names[0]

  tags = {
    Name = "${var.stack}-db_subnet-1"
  }
}

resource "aws_subnet" "db_subnet2" {
  vpc_id     = aws_vpc.wordpress_vpc.id
  cidr_block = "10.0.201.0/24"

  availability_zone = data.aws_availability_zones.azs.names[1]

  tags = {
    Name = "${var.stack}-db_subnet-2"
  }
}

resource "aws_subnet" "db_subnet3" {
  vpc_id            = aws_vpc.wordpress_vpc.id
  cidr_block        = "10.0.202.0/24"
  availability_zone = data.aws_availability_zones.azs.names[2]

  tags = {
    Name = "${var.stack}-db_subnet-3"
  }
}