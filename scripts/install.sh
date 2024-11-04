sudo apt update
sudo apt install curl git wget -y

# check if nvidia driver is installed
if [ -x "$(command -v nvidia-smi)" ]; then
    echo "Nvidia driver is installed"
else
    echo "Nvidia driver is not installed"
    echo "Please install Nvidia driver"
    exit 1
fi

#check if docker is installed
if [ -x "$(command -v docker)" ]; then
    echo "Docker is already installed"
else
    echo "Docker is not installed"
    #install docker 
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
fi

# check if nvidia-container-toolkit is installed
if [ -x "$(command -v nvidia-container-toolkit)" ]; then
    echo "Nvidia-container-toolkit is installed"
else
    echo "Nvidia-container-toolkit is not installed"
    #install nvidia-container-toolkit
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
    curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
    curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
    sudo apt update
    sudo apt install nvidia-container-toolkit -y
    sudo nvidia-ctk runtime configure --runtime=docker
    sudo systemctl restart docker
fi
#check if k3d is installed
if [ -x "$(command -v k3d)" ]; then
    echo "k3d is already installed"
else
    echo "k3d is not installed"
    #install k3d
    wget -q -O - https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
fi

#check if kubectl is installed
if [ -x "$(command -v kubectl)" ]; then
    echo "kubectl is already installed"
else
    echo "kubectl is not installed"
    #install kubectl
    curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
    kubectl create -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.17.0/deployments/static/nvidia-device-plugin.yml
fi

#check if helm is installed
if [ -x "$(command -v helm)" ]; then
    echo "helm is already installed"
else
    echo "helm is not installed"
    #install helm
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
fi

#check if k9s is installed
if [ -x "$(command -v k9s)" ]; then
    echo "k9s is already installed"
else
    echo "k9s is not installed"
    #install k9s
    wget https://github.com/derailed/k9s/releases/download/v0.32.5/k9s_linux_amd64.deb
    sudo apt install ./k9s_linux_amd64.deb
    sudo rm -rf k9s_linux_amd64.deb
fi


echo "nvidia-kubernetes-plugin is not installed"
#install nvidia-kubernetes-plugin
helm repo add nvdp https://nvidia.github.io/k8s-device-plugin
helm repo update
helm upgrade -i nvdp nvdp/nvidia-device-plugin \
--namespace nvidia-device-plugin \
--create-namespace \
--version 0.17.0

