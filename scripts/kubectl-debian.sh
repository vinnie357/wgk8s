function kubectl-debian {
# Install the kubectl
echo "Downloading kubectl..."
sudo curl -sSL -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
sudo chmod +x /usr/local/bin/kubectl
}
