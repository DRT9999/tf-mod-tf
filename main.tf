resource "aws_instance" "main" {
  ami                    = data.aws_ami.main.image_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.main.id]
  tags = {
    Name    = "${var.name}-${var.env}"
    Monitor = "yes"
  }

  # We will soon remove this option and this is a workAround
  lifecycle {
    ignore_changes = [ami]
  }
}

# Creates DNS Record
resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.main.id
  name    = "${var.name}-${var.env}.exp.in"
  type    = "A"
  ttl     = 10
  records = [aws_instance.main.private_ip]

  lifecycle {
    ignore_changes = [zone_id]
  }
}

resource "null_resource" "app" {
  depends_on = [aws_route53_record.main, aws_instance.main]

  triggers = {
    always_run = timestamp()
  }
  connection { # Enables connection to the remote host
    host     = aws_instance.main.private_ip
    user     = "ec2-user"
    password = var.ssh_pwd
    type     = "ssh"
  }
  provisioner "remote-exec" { # This let's the execution to happen on the remote node
    inline = [
      "pip3.11 install hvac",
      "ansible-pull -U https://github.com/DRT9999/Ansible_App.git -e vault_token=${var.vault_token} -e COMPONENT=${var.name} -e ENV=${var.env} expense-pull.yml"
    ]
  }
}

# hvac:  a pre-req package for hashicorp modules
# ref: https://docs.ansible.com/ansible/latest/collections/community/hashi_vault/hashi_vault_lookup.html#ansible-collections-community-hashi-vault-hashi-vault-lookup# resource "aws_instance" "Expenes" {
#     ami                     = data.aws_ami.amiid.image_id  #"ami-0fcc78c828f981df2"
#     instance_type           = var.instance_type #try (each.value["instance_type"], null) == ".*" ? each.value["instance_type"] : "t2.small"
#     vpc_security_group_ids  = [aws_security_group.sg.id]  #var.vpc_security_group_ids  #["sg-052508cac91923258"] 

#     tags = {
#         Name = "${var.name}-${var.env}"
#     }
# }

# resource "aws_route53_record" "DNS" {
#   zone_id = data.aws_route53_zone.main.zone_id
#   name    = "${var.name}-${var.env}.exp.in"
#   type    = "A"
#   ttl     = 10
#   records = [aws_instance.Expenes.private_ip]
# }

# resource "null_resource" "exp" {
#   depends_on = [ aws_route53_record.DNS ,aws_instance.Expenes ]  
#   triggers = {
#     always_run = true
#   }
#   provisioner "local-exec" {
#     command = "sleep 20 ; cd /home/ec2-user/Ansible/APrometheus ; ansible-playbook -i inv-dev  -e ansible_user=ec2-user -e ansible_password=DevOps321 -e COMP=${var.name} -e env=dev -e pwd=ExpenseApp@1 expense.yml"
#   } #${aws_instance.Expenes.private_ip},
# }

