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
