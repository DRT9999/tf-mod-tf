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

data "aws_ami" "amiid" {
  most_recent      = true
  name_regex       = "RAVITEJA"  #"ami-0fcc78c828f981df2"
  owners           = ["469861001016"]
}
