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

variable "tuple_vars" {
    type = tuple([ string,number,string ])
    default = [ "apple",10,"peach" ]
}

variable "object_vars" {
    type = object({
      name = string
      port = list(number)
    })
    default = {
      name = "open_ports"
      port = [ 22,80,443 ]
    }
}

variable "input_vars" {
    type = string
    description = "plz input something here"    
}

