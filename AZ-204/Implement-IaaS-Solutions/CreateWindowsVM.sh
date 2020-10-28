az login

az group create --name az204learn --location eastus

az vm create \
    --resource-group az204learn \
    --name myVM \
    --image win2016datacenter \
    --admin-username azure204admin

az vm open-port --port 80 --resource-group az204learn --name myVM

mstsc /v:{publicIpAddress}

az group delete --name az204learn