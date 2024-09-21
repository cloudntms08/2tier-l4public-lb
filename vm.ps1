$rgname = "rg7"
$location = "eastus"
$adminpassword = "123#ntms123#"
$adminU = "vmadmin"
$vmBaseName = "web"  
$size = "standard_DS1_v2"
$vnetname = "ntmsvnet"
$subnet = "webSubnet"
$vmCount = "2"


az group create -n $rgname -l $location

az network vnet create `
    --resource-group $rgname `
    --name $vnetname `
    --address-prefixes "10.1.0.0/16" `
    --subnet-name $subnet `
    --subnet-prefixes "10.1.1.0/24"

for ($i = 1; $i -le $vmCount; $i++) {
    $vmName = "$vmBaseName$i"
    az vm create `
        --resource-group $rgname `
        --name $vmName `
        --image win2022datacenter `
        --size $size `
        --admin-username $adminU `
        --admin-password $adminpassword `
        --vnet-name $vnetname `
        --subnet $subnet `
        --public-ip-address '""' `
        --nsg '""' 
}

for ($i = 1; $i -le $vmCount; $i++) {
    $vmName = "$vmBaseName$i"
    az vm extension set `
        --resource-group $rgname `
        --vm-name $vmName `
        --name CustomScriptExtension `
        --publisher Microsoft.Compute `
        --version 1.10 `
        --settings '{\"commandToExecute\": \"powershell Add-WindowsFeature Web-Server\"}'
}

az network nsg create `
  --resource-group $rgname `
  --name webNSG 

az network vnet subnet update `
  --resource-group $rgname `
  --vnet-name $vnetname `
  --name $subnet `
  --network-security-group webNSG

az network nsg rule create `
  --resource-group $rgname  `
  --nsg-name webNSG `
  --name Allow-RDP `
  --protocol Tcp `
  --priority 1000 `
  --destination-port-ranges 3389 `
  --access Allow `
  --direction Inbound `
  --source-address-prefixes '*' `
  --destination-address-prefixes '*'

az network nsg rule create `
  --resource-group $rgname  `
  --nsg-name webNSG `
  --name Allow-http `
  --protocol Tcp `
  --priority 1001 `
  --destination-port-ranges 80 `
  --access Allow `
  --direction Inbound `
  --source-address-prefixes '*' `
  --destination-address-prefixes '*'

  az network public-ip create `
  --resource-group $rgname `
  --name lbPublicIP `
  --sku Standard


az network lb create `
  --resource-group $rgname `
  --name ntmsLoadBalancer `
  --sku Standard `
  --frontend-ip-name ntmsFrontend `
  --public-ip-address lbPublicIP

az network lb probe create `
  --resource-group $rgname `
  --lb-name ntmsLoadBalancer `
  --name ntmsHealthProbe `
  --protocol Tcp `
  --port 80

az network lb rule create `
  --resource-group $rgname `
  --lb-name ntmsLoadBalancer `
  --name ntmsLoadBalancingRule `
  --protocol Tcp `
  --frontend-port 80 `
  --backend-port 80 `
  --frontend-ip-name ntmsFrontend `
  --probe-name ntmsHealthProbe `
  --idle-timeout 4 `
  --load-distribution Default



