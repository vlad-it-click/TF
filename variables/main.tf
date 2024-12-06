variable "string_var" {
  type = string
  default = "default string variable"
}

variable "number_var" {
    type = number
    default = 100
}

variable "bool_var" {
   default = false  
}

variable "list_vars" {
    type = list(string)
    default = [ "apple", "peach" ]
}

variable "list_vars" {
    type = list(number)
    default = [ 10, 20 ]
}

variable "map_vars" {
    type = map
    default = {
        key1 = "value1"
        key2 = "value2"
    }
}

variable "input_vars" {
    type = string
    description = "plz input something here"    
}

