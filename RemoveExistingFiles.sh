#!/bin/bash
yum update -y
yum install -y nginx
rm -rf /usr/share/nginx/html/index.html
service nginx start


RG=DELETELATER
echo "Creating Azure Resource Group"
az group create --location eastus -n ${RG}

echo "Creating Azure Virtual Network"
az network vnet create -g ${RG} -n ${RG}-vNET1 --address-prefix 10.1.0.0/16 \
--subnet-name ${RG}-Subnet-1 --subnet-prefix 10.1.1.0/24 -l eastus

echo "Creating Azure Subnet"
az network vnet subnet create -g ${RG} --vnet-name ${RG}-vNET1 -n AzureFirewallSubnet \
--address-prefixes 10.1.2.0/24
az network vnet subnet create -g ${RG} --vnet-name ${RG}-vNET1 -n AzureVNGSubnet \
--address-prefixes 10.1.3.0/24

echo "Create Azure NSG & Rules"
az network nsg create -g ${RG} -n ${RG}_NSG1
az network nsg rule create -g ${RG} --nsg-name ${RG}_NSG1 —n ${RG}_NSG1_RULE1 --priority 100 \
--source-address-prefixes '*' --source-port-ranges '*' --destination-address-prefixes '*' \
--destination-port-ranges '*' --access Allow --protocol Tcp --description "Allowing All Traffic For Now"



echo "Creating Azure Virtual Machine"
az vm create --resource-group ${RG} --name WINVM1 --image win2019Datacenter --vnet-name ${RG}-vNET1 \
--subnet ${RG}-Subnet-1 --admin-username adminsree --admin-password "India@123456" --size Standard_B2ms \
--nsg ${RG}_NSG1



Install-module Az -AllowC10bber -Verbose -Force

#Using AccessKey Connection String
$connectionstring = 'DefaultEndpointsProtocol=https;AccountName=azureb17storageaccount;AccountKey=/QJ5m2yCLgAH2Luigtuemy9dMBd6I6FUdeiao8QSbRPYBea7nav7fdxBdOuZakeEapi9pOTTPpEvyLbtzm1d0g==;EndpointSuffix=core.windows.net'
$StorageAccountName = "AZUREB25STORAGE"
$ctx = New-AzStorageContext  -ConnectionString $connectionstring
$container_name = 'testcontainer2'
$blobs = Get-AzStorageBlob -Container $container_name -Context $ctx
foreach ($blob in $blobs){
#Write-Output $blob | select Name, Length
Get-AzStorageBlobContent -Container $container_name -Blob $blob.Name -Destination "C:\test\" -Context $ctx
}
dir C:\test


#Using AccessKey and Storage Account Name
$StorageAccountName = "azureb17storageaccount"
$StorageAccountKey = "/QJ5m2yCLgAH2Luigtuemy9dMBd6I6FUdeiao8QSbRPYBea7nav7fdxBdOuZakeEapi9pOTTPpEvyLbtzm1d0g=="
$ctx = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
#Write-Output $ctx
$container_name = 'testcontainer2'
$blobs = Get-AzStorageBlob -Container $container_name -Context $ctx
foreach ($blob in $blobs){
Write-Output $blob | select Name, Length
Get-AzStorageBlobContent -Container $container_name -Blob $blob.Name -Destination "C:\test\" -Context $ctx
}
dir C:\test

#Get Token From Azure AD to Talk with Storage Account
$response = Invoke-WebRequest -Uri 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fmanagement.azure.com%2F' -Method GET -Headers @{Metadata = "true" }
$content = $response.Content | ConvertFrom-Json
$KeyVaultToken = $content.access_token
Write-Output "The AzureAD Token is: $KeyVaultToken"
Write-Output "========================================================================"


$params = @{canonicalizedResource = "/blob/AZUREB25STORAGE/testcontainer2"; signedResource = "c"; signedPermission = "rcwl"; signedProtocol = "https"; signedExpiry = "2021-08-15T00:00:00Z" }
$jsonParams = $params | ConvertTo-Json
#Write-Output $jsonParams
$sasResponse = Invoke-WebRequest -Uri https://management.azure.com/subscriptions/298f2c19-014b-4195-b821-e3d8fc25c2a8/resourceGroups/DELETELATER/providers/Microsoft.Storage/storageAccounts/AZUREB25STORAGE/listServiceSas/?api-version=2017-06-01 -Method POST -Body $jsonParams -Headers @{Authorization = "Bearer $KeyVaultToken" }
$sasContent = $sasResponse.Content | ConvertFrom-Json
$sasCred = $sasContent.serviceSasToken
Write-Output "The Storage SAS Token is: $sasCred"
Write-Output "============================================================================="


$ctx = New-AzStorageContext -StorageAccountName AZUREB25STORAGE -SasToken $sasCred
$container_name = 'testcontainer2'
$blobs = Get-AzStorageBlob -Container $container_name -Context $ctx
foreach ($blob in $blobs) {
    Write-Output $blob | select Name, Length
    Get-AzStorageBlobContent -Container $container_name -Blob $blob.Name -Destination "C:\test\" -Context $ctx
}



# Storage Account Blob Access Using SAS ConnectionString:

$connectionstring = 'BlobEndpoint=https://azureb18storageaccount1.blob.core.windows.net/;QueueEndpoint=https://azureb18storageaccount1.queue.core.windows.net/;FileEndpoint=https://azureb18storageaccount1.file.core.windows.net/;TableEndpoint=https://azureb18storageaccount1.table.core.windows.net/;SharedAccessSignature=sv=2020-08-04&ss=b&srt=sco&sp=rwlactf&se=2021-09-12T08:27:04Z&st=2021-09-11T00:27:04Z&sip=13.68.249.190&spr=https&sig=WSRW1ggKo8vjx1y%2Fy8gd%2BOpYxFKH7SyhXz6s5m5wAxc%3D'
$StorageAccountName = "AZUREB25STORAGE"
$ctx = New-AzStorageContext  -ConnectionString $connectionstring
$container_name = 'testcontainer2'
$blobs = Get-AzStorageBlob -Container $container_name -Context $ctx
foreach ($blob in $blobs){
#Write-Output $blob | select Name, Length
Get-AzStorageBlobContent -Container $container_name -Blob $blob.Name -Destination "C:\test\" -Context $ctx
}

#to delete downloaded files in testcontainer2 in azure storage container use below script

foreach ($blob in $blobs){
    Remove-AzStorageBlob -Container $container_name  -Context $ctx -Blob $blob.Name
}


RG=DELETELATER
echo "Creating Azure Virtual Machine"
az vm create --resource-group ${RG} --name MONLINXVM10 --image UbuntuLTS --vnet-name ${RG}-vNET1 \
--subnet ${RG}-Subnet-1 --admin-username adminsree --admin-password "India@123456" --size Standard_B1ms \
--nsg ""

df -h

RG=AZURESQL
echo "Creating Azure Resource Group"
az group create --location eastus -n ${RG}

echo "Creating Azure Virtual Network"
az network vnet create -g ${RG} -n ${RG}-vNET1 --address-prefix 10.1.0.0/16 \
--subnet-name ${RG}-Subnet-1 --subnet-prefix 10.1.1.0/24 -l eastus

az network vnet subnet create -g ${RG} --vnet-name ${RG}-vNET1 -n EP-Subnet-1 \
--address-prefixes 10.1.2.0/24

echo "Creating Azure Virtual Machine"
az vm create --resource-group ${RG} --name WINVM1 --image win2019Datacenter --vnet-name ${RG}-vNET1 \
--subnet ${RG}-Subnet-1 --admin-username adminsree --admin-password "India@123456" --size Standard_B2ms \
--nsg ""




az sql db replica create -g AZURESQL -s azb25westserver01 -n eastdb01 --partner-server azb25westserver01 --service-objective Basic