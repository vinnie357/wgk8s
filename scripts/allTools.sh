function allTools {
    # Install all tools
    echo "Installing all tools..."
    # pre-commit
    echo "Installing pre-commit..."
    pip3 install pre-commit
    # constellation
    echo "Installing constellation..."
    # source constellation-debian.sh
    #. constellation-debian
    # run install function
    constellation-debian
    # kubectl
    echo "Installing kubectl..."
    # source kubectl-debian.sh
    #. kubectl-debian
    # run install function
    kubectl-debian
    # helm
    echo "Installing helm..."
    # source helm-debian.sh
    #. helm-debian
    # run install function
    helm-debian
    # terraform
    echo "Installing terraform..."
    # source terraform-debian.sh
    #. terraform-debian
    # run install function
    terraform-debian
    # azure-cli
    echo "Installing azure-cli..."
    # source azure-cli-debian.sh
    #. azure-cli-debian
    # run install function
    azurecli-debian
    # gcloud
    echo "Installing gcloud..."
    # source gcloud-debian.sh
    #. gcloud-debian
    # run install function
    gcloud-debian
    # tailscale
    echo "Installing tailscale..."
    # source tailscale-debian.sh
    #. tailscale-debian
    # run install function
    tailscale-debian
    echo "==== allTools done ===="
}
