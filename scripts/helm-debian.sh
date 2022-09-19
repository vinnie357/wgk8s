function helm-debian {
  # Install Helm
echo "Installing Helm..."
curl -s https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | sudo bash -
echo "HelmmDone!"
}
