resource "aws_vpc" "core_vpc" {
  cidr_block  = lookup(var.vpc_cidr, "pavlina_prod_byoi")
  enable_dns_hostnames  = false
  instance_tenancy = "default"

  tags = {
    Name = "pavlina_prod_byoi"
    Environment = lookup(var.taggings, "environment")
  }
}

resource "aws_subnet" "pavlina_prod_byoi_public_subnet_1" {
    vpc_id = aws_vpc.core_vpc.id
    cidr_block = lookup(var.subnets, "pavlina_prod_byoi_public_subnet_1")
    availability_zone = var.availability_zone_A
    map_public_ip_on_launch = true

    tags = {
        Name        = "pavlina_prod_byoi_public_subnet_1"
        Environment = lookup(var.taggings, "environment")
        Type        =  "public_subnet" 
    }
}

resource "aws_subnet" "pavlina_prod_byoi_public_subnet_2" {
    vpc_id = aws_vpc.core_vpc.id
    cidr_block = lookup(var.subnets, "pavlina_prod_byoi_public_subnet_2")
    availability_zone = var.availability_zone_B

    tags = {
        Name        = "pavlina_prod_byoi_public_subnet_2"
        Environment = lookup(var.taggings, "environment")
        Type        =  "public_subnet" 
    }
}

resource "aws_subnet" "pavlina_prod_byoi_private_subnet_db_1" {
    vpc_id = aws_vpc.core_vpc.id
    cidr_block = lookup(var.subnets, "pavlina_prod_byoi_private_subnet_db_1")
    availability_zone = var.availability_zone_A

    tags = {
        Name        = "pavlina_prod_byoi_private_db_subnet_1"
        Environment = lookup(var.taggings, "environment")
        Type        =  "private_db_subnet" 
    }
}

resource "aws_subnet" "pavlina_prod_byoi_private_subnet_db_2" {
    vpc_id = aws_vpc.core_vpc.id
    cidr_block = lookup(var.subnets, "pavlina_prod_byoi_private_subnet_db_2")
    availability_zone = var.availability_zone_B

    tags = {
        Name        = "pavlina_prod_byoi_private_db_subnet_2"
        Environment = lookup(var.taggings, "environment")
        Type        =  "private_db_subnet" 
    }
}

resource "aws_subnet" "pavlina_prod_byoi_private_subnet_app_1" {
    vpc_id = aws_vpc.core_vpc.id
    cidr_block = lookup(var.subnets, "pavlina_prod_byoi_private_subnet_app_1")
    availability_zone = var.availability_zone_A

    tags = {
        Name        = "pavlina_prod_byoi_private_subnet_app_1"
        Environment = lookup(var.taggings, "environment")
        Type        =  "private_app_subnet" 
    }
}

resource "aws_subnet" "pavlina_prod_byoi_private_subnet_app_2" {
    vpc_id = aws_vpc.core_vpc.id
    cidr_block = lookup(var.subnets, "pavlina_prod_byoi_private_subnet_app_2")
    availability_zone = var.availability_zone_B

    tags = {
        Name        = "pavlina_prod_byoi_private_subnet_app_2"
        Environment = lookup(var.taggings, "environment")
        Type        =  "private_app_subnet" 
    }
}


resource "aws_route_table" "pavlina_public" {
    vpc_id  =   aws_vpc.core_vpc.id

    route {
        cidr_block  =   "0.0.0.0/0"
        gateway_id  =   aws_internet_gateway.pavlina_prod_byoi_igw.id
    }
    tags = {
        Name = "${lookup(var.taggings, "customer")}_public_route_table"
        Environment = lookup(var.taggings, "environment")
        Solution    = lookup (var.taggings, "solution")
    }
}

resource "aws_route_table" "pavlina_private_application" {
    vpc_id  =   aws_vpc.core_vpc.id

    route {
        cidr_block  =   "0.0.0.0/0"
        nat_gateway_id  =   aws_nat_gateway.pavlina_prod_byoi_nat_gw.id
    } 
    tags = {
        Name = "${lookup(var.taggings, "customer")}_private_app_route_table"
        Environment = lookup(var.taggings, "environment")
        Solution    = lookup (var.taggings, "solution")
    }
}

resource "aws_route_table" "pavlina_private_db" {
    vpc_id  =   aws_vpc.core_vpc.id

    tags = {
        Name = "${lookup(var.taggings, "customer")}_private_db_route_table"
        Environment = lookup(var.taggings, "environment")
        Solution    = lookup (var.taggings, "solution")
    }
}

resource "aws_route_table_association" "route_public_a" {
    subnet_id   =   aws_subnet.pavlina_prod_byoi_public_subnet_1.id
    route_table_id  =   aws_route_table.pavlina_public.id
}

resource "aws_route_table_association" "route_public_b" {
    subnet_id   =   aws_subnet.pavlina_prod_byoi_public_subnet_2.id
    route_table_id  =   aws_route_table.pavlina_public.id
}

resource "aws_route_table_association" "route_private_app_a" {
    subnet_id   =   aws_subnet.pavlina_prod_byoi_private_subnet_app_1.id
    route_table_id  =   aws_route_table.pavlina_private_application.id
}

resource "aws_route_table_association" "route_private_app_b" {
    subnet_id   =   aws_subnet.pavlina_prod_byoi_private_subnet_app_2.id
    route_table_id  =   aws_route_table.pavlina_private_application.id
}

resource "aws_route_table_association" "route_private_db_a" {
    subnet_id   =   aws_subnet.pavlina_prod_byoi_private_subnet_db_1.id
    route_table_id  =   aws_route_table.pavlina_private_db.id
}

resource "aws_route_table_association" "route_private_db_b" {
    subnet_id   =   aws_subnet.pavlina_prod_byoi_private_subnet_db_2.id
    route_table_id  =   aws_route_table.pavlina_private_db.id
}

resource "aws_internet_gateway" "pavlina_prod_byoi_igw" {
    vpc_id  =   aws_vpc.core_vpc.id
    tags = {
        Name = "${lookup(var.taggings, "customer")}-igw"
        Environment = lookup(var.taggings, "environment")
        Solution = lookup(var.taggings, "solution")
    }
}

resource "aws_eip" "nat_eip" {
    vpc = true
}

 resource "aws_nat_gateway" "pavlina_prod_byoi_nat_gw" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id     = aws_subnet.pavlina_prod_byoi_public_subnet_1.id

    tags = {
        Name = "${lookup(var.taggings, "customer")}_nat_gw"
        Environment = lookup(var.taggings, "environment")
        Solution = lookup(var.taggings, "solution")
    }
} 