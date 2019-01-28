#
# Workstation External IP
#
# This configuration is required and is
# provided as an example to easily fetch
# the external IP of your local workstation to
# configure inbound EC2 Security Group access
# to the Kubernetes cluster.
#


data "http" "workstation-external-ip" {
  url = "http://ipv4.icanhazip.com"
}


#variable "workstation-external-cidr" {
#  default = ""
#}

#Override with variable or hardcoded value if necessary
locals {
  workstation-external-cidr = "${chomp(data.http.workstation-external-ip.body)}/32"
}

output "workstation-external-cidr"{
  value = "${local.workstation-external-cidr}"
}