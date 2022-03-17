# AHB-scripts
Powershell scripts to scan Azure subscriptions, report Azure Hybrid Benefit(AHB) status and set AHB status to active.
ListAllVMsInSubscription scans subscriptions for VM meta data on AHB. Generates a CSV report of on use of AHB for WS & SQL.
ChangeLicenseType adds Windows AHB to all Windows VMs. Does not affect the VM. See comments in script.
