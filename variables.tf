variable "region" {
    type = string
}

variable "vpc_cidr" {
    type = map(string)
}

variable "subnets" {
    type = map(string)
}

variable "availability_zone_A" {
    type = string
}

variable "availability_zone_B" {
    type = string
}

variable "taggings" {
    type = map(string)

    default = {
        customer    =   "pavlina"
        environment =   "prod"
        solution    =   "byoi"
    }
} 

variable "namespace" {}