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

