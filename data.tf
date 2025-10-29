data "aws_route53_zone" "main" {
    name = "exp.in"
    private_zone = true
}

# data "aws_security_group" "name" {
#     filter {
#       name = "group-name"
#       values = ["ALL"]
#     }
# }

data "aws_ami" "main" {
  most_recent      = true
  name_regex       = "ami-03255eaab63f1ae4b" #"RAVITEJA1"  #"ami-0fcc78c828f981df2"
  owners           = ["469861001016"]
}
