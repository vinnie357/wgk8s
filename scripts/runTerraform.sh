#!/bin/bash
function runTerraform {
terraform init
terraform fmt
terraform validate
terraform plan
echo "running: $PWD"
read -p "Press enter to continue"
terraform apply --auto-approve
}
