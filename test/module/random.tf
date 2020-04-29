variable "hellos" {
  type = object({
    hello        = string
    second_hello = string
  })
  description = "list of hellos"
}

variable "secret_key" {
  type        = string
  description = "this is a secret"
}

resource "random_pet" "server" {
  keepers = {
    hello      = var.hellos.hello
    secret_key = var.secret_key
  }
}

resource "random_pet" "number_2" {
  keepers = {
    hello = var.hellos.second_hello
  }
}

output "pet" {
  value = random_pet.server.id
}

output "list_of_pets" {
  value = [random_pet.server.id, random_pet.number_2.id]
}