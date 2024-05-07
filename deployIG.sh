# Define Environment Variables
export RANDOM_ID="$(openssl rand -hex 3)"
export MY_RESOURCE_GROUP_NAME="myRG$RANDOM_ID"
export REGION="eastus"
export MY_AKS_CLUSTER_NAME="myAKSTestCluster$RANDOM_ID"

# Create a resource group
az group create --name $MY_RESOURCE_GROUP_NAME --location $REGION

# Create AKS Cluster
az aks create \
  --resource-group $MY_RESOURCE_GROUP_NAME \
  --name $MY_AKS_CLUSTER_NAME \
  --location $REGION \
  --no-ssh-key

# Connect to the cluster
if ! [ -x "$(command -v kubectl)" ]; then az aks install-cli; fi

az aks get-credentials --resource-group $MY_RESOURCE_GROUP_NAME --name $MY_AKS_CLUSTER_NAME --overwrite-existing

kubectl get nodes

# Installing the kubectl plugin: `gadget`
IG_VERSION=$(curl -s https://api.github.com/repos/inspektor-gadget/inspektor-gadget/releases/latest | jq -r .tag_name)
IG_ARCH=amd64
mkdir -p $HOME/.local/bin
export PATH=$PATH:$HOME/.local/bin
curl -sL https://github.com/inspektor-gadget/inspektor-gadget/releases/download/${IG_VERSION}/kubectl-gadget-linux-${IG_ARCH}-${IG_VERSION}.tar.gz  | tar -C $HOME/.local/bin -xzf - kubectl-gadget

kubectl gadget version

# Installing Inspektor Gadget in the cluster
kubectl gadget deploy

kubectl gadget version

kubectl gadget help
