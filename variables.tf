variable "region" {
  type = string 
  default = "us-east-1"
}

variable "namespace" {
    description = "The project namespace to use for unique resource naming"
    type = string
    default = "pavlina_prod_byoi"
}

variable "availability_zone_A" {
    type = string
    default = "us-east-1a"
}

variable "availability_zone_B" {
    type = string
    default = "us-east-1b"
}

variable "vpc_cidr" {
    type = map(string)

    default = {
        pavlina_prod_byoi = "10.0.0.0/16"
    }
}

variable "subnets" {
    type = map(string)

    default = {
        pavlina_prod_byoi_public_subnet_1      = "10.0.10.0/28"
        pavlina_prod_byoi_public_subnet_2      = "10.0.11.0/28"
        pavlina_prod_byoi_private_subnet_db_1  = "10.0.12.0/28"
        pavlina_prod_byoi_private_subnet_db_2  = "10.0.13.0/28"
        pavlina_prod_byoi_private_subnet_app_1 = "10.0.14.0/28"
        pavlina_prod_byoi_private_subnet_app_2 = "10.0.15.0/28"
    }
}