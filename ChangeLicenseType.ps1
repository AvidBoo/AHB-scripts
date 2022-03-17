Set-StrictMode -Version 1.0
#
#Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
# Comment out if module not imported
Import-Module Az

if ([string]::IsNullOrEmpty($(Get-AzContext).Account)){(Login-AzAccount)}

#Enter $null if you want all subscriptions scanned.   
$SubscriptionId = $null 
$Subscriptions = Get-Azsubscription

if ($SubscriptionId)
{
    $Subscriptions = $Subscriptions | Where-Object { $_.SubscriptionId -EQ $SubscriptionId }
}

$i=0

foreach ( $Subscription in $Subscriptions ) {

    $SubscriptionId = $Subscription.SubscriptionId

     (Select-AzSubscription -SubscriptionId $SubscriptionId)>0

    # Display progress, this script may take a while
    $i++
    Write-Progress -activity $subscription.Name -PercentComplete ($i/$Subscriptions.Count*100)

    # Get all of the VM's:
    # ($vms=Get-AzVM) > 0
    $vms = Get-AzVM | Where-Object{$_.LicenseType -notlike "Windows_Server" -and $_.StorageProfile.OsDisk.OsType -like "Windows" } 
    $vmNum = 0
    $vmCount = $vms.Count

    # Add info about VM's from the Resource Manager to the array
    foreach ($vm in $vms)
    {    
        $vmNum++
        Write-Progress -activity $vm.Name -PercentComplete ($vmNum/$vmCount*100)

        try{
            $vm = Get-AzVM -ResourceGroup  $vm.ResourceGroupName -Name $vm.Name
            $vm.LicenseType = "Windows_Server"  # Use None for PAYGO i.e., NO AHB. Use Windows_Server for AHB
            Update-AzVM -ResourceGroupName $vm.ResourceGroupName -VM $vm

    }
    catch{
        Write-Output "Problem VM Name: $($vm.Name) in $($Subscription.Name) - Error Message: [$($_.Exception.Message)]"
    }

       
    }
}
