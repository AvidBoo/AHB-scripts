# AHB-scripts
Powershell scripts to scan Azure subscriptions, report AHB status and set AHB status to active.
ListAllVMsInSubscription scans subscriptions for VM meta data on AHB. Generates a CSV report of VM details include AHB status for WS & SQL.
ChangeLicenseType adds Windows AHB to all Windows VMs. Does not affect the VM. See comments in script.
