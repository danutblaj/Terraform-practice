variable "ami-id" {
    type        = string
    default     = "ami-05ff5eaef6149df49"
    description = "AMI id for the ec2 instance"
}

variable "instance_type" {
    type = string
    default = "t2.micro"
    description = "ec2 instance type"
}
variable "role_name" {
    type = list(string)
    description = "name for the s3 and db access roles"
    default = ["s3_access","db-access"]
}
variable "subnet_count" {
    type = map(number)
    default = {  
        public  = 1, 
        private = 2
    }

}
variable "public_cidr_block" {
    type = string
    default = "10.0.1.0/24"
}
variable "private_cidr_block" {
    type = list(string)
    default = [
        "10.0.101.0/24",
        "10.0.102.0/24"
    ]
}
variable "s3_bucket" {
    type = string
    description = "name for the s3 bucket"
}