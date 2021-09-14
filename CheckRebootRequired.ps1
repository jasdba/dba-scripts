$pendingRebootTests = @(
    @{
        Name = 'RebootPending'
        Test = { Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing'  -Name 'RebootPending' -ErrorAction Ignore }
        TestType = 'ValueExists'
    }
    @{
        Name = 'RebootRequired'
        Test = { Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update'  -Name 'RebootRequired' -ErrorAction Ignore }
        TestType = 'ValueExists'
    }
    @{
        Name = 'PendingFileRenameOperations'
        Test = { Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name 'PendingFileRenameOperations' -ErrorAction Ignore }
        TestType = 'NonNullValue'
    }
)

## Create a PowerShell Remoting session
$session1, $session2, $session3 = New-PSSession -ComputerName HQCADSQL01.cad.lond-amb.nhs.uk, HQCADSQL02.cad.lond-amb.nhs.uk, BWCADSQL02.cad.lond-amb.nhs.uk -Credential CAD\admin.jaseem 
foreach ($test in $pendingRebootTests) {
    $result = Invoke-Command -Session $session1, $session2, $session3 -ScriptBlock $test.Test
}

$session1, $session2, $session3 = New-PSSession -ComputerName HQCADSQL01.cad.lond-amb.nhs.uk, HQCADSQL02.cad.lond-amb.nhs.uk, BWCADSQL02.cad.lond-amb.nhs.uk -Credential CAD\admin.jaseem 
foreach ($test in $pendingRebootTests) {
    $result = Invoke-Command -Session $session1, $session2, $session3 -ScriptBlock $test.Test
    if ($test.TestType -eq 'ValueExists' -and $result) {
        $session1.ComputerName, $true
        $session2.ComputerName, $true
        $session3.ComputerName, $true
    } elseif ($test.TestType -eq 'NonNullValue' -and $result -and $result.($test.Name)) {
        $session1.ComputerName, $true
        $session2.ComputerName, $true
        $session3.ComputerName, $true
    } else {
        $session1.ComputerName, $false
        $session2.ComputerName, $false
        $session3.ComputerName, $false
    }
}
$session1, $session2, $session3 | Remove-PSSession