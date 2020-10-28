# https://docs.microsoft.com/en-us/azure/virtual-machines/windows/quick-create-powershell
Connect-AzAccount
$rg = "az204learn"
$vmName = "az204testVM"

Write-Output('Creating resource group')
New-AzResourceGroup -Name $rg -Location EastUS

Write-Output('Creating VM')
New-AzVm `
    -ResourceGroupName $rg `
    -Name $vmName `
    -Location "East US" `
    -VirtualNetworkName "az204testVnet" `
    -SubnetName "az204testSubnet" `
    -SecurityGroupName "az204testNSG" `
    -PublicIpAddressName "az204testPublicIP" `
    -OpenPorts 80,3389

# Get public IP of the VM
$ip = Get-AzPublicIpAddress -ResourceGroupName $rg | Select-Object "IpAddress"
Write-Output($ip)

# Connect to VM
mstsc.exe /v:$ip

# Resize VM
Get-AzVMSize -Location "EastUS"
$vm = Get-AzVM -ResourceGroupName $rg -VMName $vmName
$vm.HardwareProfile.VmSize = "Standard_DS3_v2"
Update-AzVM -VM $vm -ResourceGroupName $rg

# Start stop VM
Stop-AzVM -ResourceGroupName $rg -Name $vmName -Force
Start-AzVM -ResourceGroupName $rg -Name $vmName

# Create and add disk to VM
$diskConfig = New-AzDiskConfig -Location "EastUS" -CreateOption Empty -DiskSizeGB 128
$dataDisk = New-AzDisk -ResourceGroupName $rg -DiskName "myDataDisk" -Disk $diskConfig

$vm = Get-AzVM -ResourceGroupName $rg -Name $vmName
$vm = Add-AzVMDataDisk `
    -VM $vm `
    -Name "myDataDisk" `
    -CreateOption Attach `
    -ManagedDiskId $dataDisk.Id `
    -Lun 1
Update-AzVM -ResourceGroupName $rg -VM $vm

# Install Web server on the VM
Install-WindowsFeature -name Web-Server -IncludeManagementTools

# Cleanup
Remove-AzResourceGroup -Name $rg