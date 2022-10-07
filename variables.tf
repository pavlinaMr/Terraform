variable "public_subnet1" {
}
variable "public_subnet2" {
  
}
variable "vpc_id" {
}

variable "taggings" {
    type = map(string)

    default = {
        customer    =   "pavlina"
        environment =   "prod"
        solution    =   "byoi"
    }
} 

variable "application_sg" {
  
}