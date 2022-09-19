#!bin/bash
function constellation-debian {
  version=${1:-"2.0.0"}
  os=${2:-"linux"}
  #echo "$(uname)" | tr '[:upper:]' '[:lower:]'
  arch=${3:-"amd64"}
  #dpkg --print-architecture
  # Install constellation
  echo "Installing constellation..."
  # Download constellation
  echo "Downloading constellation..."
  sudo wget https://github.com/edgelesssys/constellation/releases/download/v${version}/constellation-${os}-${arch}
  # Move constellation to /usr/local/bin
  echo "Moving constellation to /usr/local/bin..."
  sudo mv constellation-${os}-${arch} /usr/local/bin/constellation
  # Make constellation executable
  echo "Making constellation executable..."
  sudo chmod +x /usr/local/bin/constellation
  # Check constellation version
  echo "Checking constellation version..."
  constellation --version
  echo "==== constellation-debian done ===="
}
