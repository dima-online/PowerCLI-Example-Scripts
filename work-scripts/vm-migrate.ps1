$csvName = "D:\vm-migrate.csv"

$emailAddr = "d.rogozinsky@kazpost.kz"
#$startTime = $(Get-Date).AddMinutes(2)

$startTime = [Datetime] $(Get-Date -format 'MM/dd/yyyy') + "00:02" 
$startTime = $startTime.AddDays(1)

$startInterval = 2
$si = get-view ServiceInstance
$scheduledTaskManager = Get-View $si.Content.ScheduledTaskManager
$offset = 0
$powerOffset = 5
$svmOffset = 6
$onOffset = 7

Import-Csv $csvName | % {

$vm = Get-View -ViewType VirtualMachine -Filter @{"Name"=$_.VMname}

write-host "Setup migration " $_.VMname " on " $startTime.AddMinutes($offset)

# Shutdown VM
$taskstartTime = $startTime.AddMinutes($offset)
$spec = New-Object VMware.Vim.ScheduledTaskSpec
$spec.Name = "Shutdown VM " + $_.VMname + " on " + $taskstartTime
$spec.Description = "Shutdown " + $_.VMname + " on " + $taskstartTime
$spec.Enabled = $true
$spec.Notification = $emailAddr
$spec.Scheduler = New-Object VMware.Vim.OnceTaskScheduler
$spec.Scheduler.runat = $taskstartTime
$spec.Action = New-Object VMware.Vim.MethodAction
$spec.Action.Name = "ShutdownGuest"
$scheduledTaskManager.CreateScheduledTask($vm.MoRef, $spec)

# PowerOff VM
$taskstartTime = $startTime.AddMinutes($offset+$powerOffset)
$spec = New-Object VMware.Vim.ScheduledTaskSpec
$spec.Name = "Power Off VM " + $_.VMname + " on " + $taskstartTime
$spec.Description = "Power Off " + $_.VMname + " on " + $taskstartTime
$spec.Enabled = $true
$spec.Notification = $emailAddr
$spec.Scheduler = New-Object VMware.Vim.OnceTaskScheduler
$spec.Scheduler.runat = $taskstartTime
$spec.Action = New-Object VMware.Vim.MethodAction
$spec.Action.Name = "PowerOffVM_Task"
$scheduledTaskManager.CreateScheduledTask($vm.MoRef, $spec)

# Migrate VM
$taskstartTime = $startTime.AddMinutes($offset+$svmOffset)
$spec = New-Object VMware.Vim.ScheduledTaskSpec
$spec.Name = "svMotion " + $_.VMname + " on " + $taskstartTime
$spec.Description = "Migrate " + $_.VMname + " on " + $taskstartTime
$spec.Enabled = $true
$spec.Notification = $emailAddr
$spec.Scheduler = New-Object VMware.Vim.OnceTaskScheduler
$spec.Scheduler.runat = $taskstartTime
$spec.Action = New-Object VMware.Vim.MethodAction
$spec.Action.Name = "RelocateVM_Task"
$arg1 = New-Object VMware.Vim.MethodActionArgument
$arg1.Value = New-Object VMware.Vim.VirtualMachineRelocateSpec
$arg1.Value.datastore = (Get-VM -name $_.VMname | Get-Datastore | Get-View).MoRef
$arg1.Value.pool = (Get-ResourcePool -Name "Migrated VM"| Get-View).MoRef
$arg1.Value.host = (Get-Cluster -Name "Cluster5" | Get-VMHost | Get-Random).MoRef
$spec.Action.Argument += $arg1
$arg2 = New-Object VMware.Vim.MethodActionArgument
$arg2.Value = [VMware.Vim.VirtualMachineMovePriority]"defaultPriority"
$spec.Action.Argument += $arg2
$scheduledTaskManager.CreateScheduledTask($vm.MoRef, $spec)

# PowerOn VM
$taskstartTime = $startTime.AddMinutes($offset+$onOffset)
$spec = New-Object VMware.Vim.ScheduledTaskSpec
$spec.Name = "Power On VM " + $_.VMname + " on " + $taskstartTime
$spec.Description = "Power On " + $_.VMname  + " on " + $taskstartTime
$spec.Enabled = $true
$spec.Notification = $emailAddr
$spec.Scheduler = New-Object VMware.Vim.OnceTaskScheduler
$spec.Scheduler.runat = $taskstartTime
$spec.Action = New-Object VMware.Vim.MethodAction
$spec.Action.Name = "PowerOnVM_Task"
$scheduledTaskManager.CreateScheduledTask($vm.MoRef, $spec)

$offset += $startInterval
}
