#!bin/bash
function terraform-debian {
#!/bin/bash
echo "---installing terraform---"
VERSION=${1:-"1.2.9"}
os=${2:-"linux"}
arch=${3:-"amd64"}
wget https://releases.hashicorp.com/terraform/$VERSION/terraform_"$VERSION"_${os}_${arch}.zip
sudo unzip -o ./terraform_"$VERSION"_${os}_${arch}.zip -d /usr/local/bin/
rm -f ./terraform_"$VERSION"_linux_amd64.zip

echo "---terraform done---"

}
