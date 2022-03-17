Set-StrictMode -Version 1.0
#
#Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
# UnComment out if module not imported
Import-Module Az

if ([string]::IsNullOrEmpty($(Get-AzContext).Account)){(Login-AzAccount)}

#Enter $null if you want all subscriptions scanned or per subscription with "subscription guid"
#$SubscriptionId = "subsription GUID"
$SubscriptionId = $null  
$Subscriptions = Get-Azsubscription
# $home/ puts the report in the root of your personal directory
$ReportName = "AHBUsed.csv" 

if ($SubscriptionId)
{
    $Subscriptions = $Subscriptions | Where-Object { $_.SubscriptionId -EQ $SubscriptionId }
}

$vmarray = @()
$i=0
$vmstatus = $null

foreach ( $Subscription in $Subscriptions ) {

    $SubscriptionId = $Subscription.SubscriptionId

     (Select-AzSubscription -SubscriptionId $SubscriptionId)>0

    # Display progress, this script may take a while
    $i++
    Write-Progress -activity $subscription.Name -PercentComplete ($i/$Subscriptions.Count*100)

    # Get all of the VM's:
    ($vms=Get-AzVM) > 0
    $vmNum = 0
    $vmCount = $vms.Count

    # Add info about VM's from the Resource Manager to the array
    foreach ($vm in $vms)
    {    
        $vmNum++
        Write-Progress -activity $vm.Name -PercentComplete ($vmNum/$vmCount*100)

        try{
            $vmstatus = Get-AzVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Status 
            # Add values to the array: 
            $vmarray += New-Object PSObject -Property @{
                Subscription=$Subscription.Name; 
                ResourceGroupName = $vm.ResourceGroupName; 
                Location = $vm.Location;
                Name=$vm.Name; 
                PowerState=(get-culture).TextInfo.ToTitleCase(($vmstatus.statuses)[1].code.split("/")[1]); 
                OSType = $vm.StorageProfile.OsDisk.OsType; 
                OSName = $vmstatus.OsName;
                OSVersion = $vmstatus.OsVersion;
                ImageReference=$vm.StorageProfile.ImageReference.Offer + " $($vm.StorageProfile.ImageReference.Sku)"; 
                Size=$vm.HardwareProfile.VmSize; 
                NumberOfCores = (Get-AzVMSize -location $vm.Location | Where-Object { $_.name -eq $vm.HardwareProfile.VmSize }).NumberOfCores; 
                MemoryInMB = (Get-AzVMSize -location $vm.Location | Where-Object { $_.name -eq $vm.HardwareProfile.VmSize }).MemoryInMB ; 
                AhbWsByol = $vm.LicenseType;
                SQLLicenseType = (Get-AzSqlVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -ErrorAction SilentlyContinue).LicenseType ; 
                SQLEdition = (Get-AzSqlVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -ErrorAction SilentlyContinue).Sku ; 
                SQLOffer = (Get-AzSqlVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -ErrorAction SilentlyContinue).Offer ; 
                SQLManagementType = (Get-AzSqlVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -ErrorAction SilentlyContinue).SqlManagementType ; 
             } 

    }catch{
        Write-Output "Problem VM Name: $($vm.Name) in $($Subscription.Name) - Error Message: [$($_.Exception.Message)]"
    }

       
    }
}

$vmarray | Select-Object Subscription, ResourceGroupName,Location, Name,PowerState,OSType,OSName,OSVersion,
ImageReference,Size,NumberOfCores,MemoryInMB,AhbWsByol, SQLLicenseType,SQLEdition,SQLOffer,SqlManagementType | Export-Csv -NoTypeInformation -Path $ReportName
