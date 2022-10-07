variable "region" {
    type = string
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

variable "namespace" {
}

variable "db_admin_username" {
    default = "admin"
}

variable "db_admin_password" {
    default = "pm14dm1n!"
    sensitive = true
}

variable "alb_sg" {
}

variable "alb_tg_arn" {
}
variable "private_subnet_app1" {
}
variable "private_subnet_app2" {
}

variable "vpc_id" {
}

variable "private_subnet_db1" {
}
variable "private_subnet_db2" {
}
variable "application_profile" {
}