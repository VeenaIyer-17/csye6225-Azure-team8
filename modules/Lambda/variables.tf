variable "prefix" {
    type = "string"
    default = "team8"
}

variable "location" {
    type = "string"
    default = "westus2"
}

variable "environment" {
    type = "string"
    default = "dev"
}

// variable "functionapp" {
//     type = "string"
//     #default = "~/Azure/HttpTrigger.zip"
// }

variable "filepath" {
    type = string
}

resource "random_string" "storage_name" {
    length = 24
    upper = false
    lower = true
    number = true
    special = false
}