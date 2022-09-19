#!/bin/bash
function azurecli-debian {
# Install the azure cli
echo "Installing azure cli..."
# Install the Azure CLI
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
curl -sL https://packages.microsoft.com/keys/microsoft.asc | (OUT=$(sudo apt-key add - 2>&1) || echo $OUT)
sudo apt-get update && sudo apt-get install -y azure-cli
echo " azsurecli Done!"
}
