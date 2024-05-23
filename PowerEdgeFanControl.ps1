### Dell Fan Control Commands
#
# enable pci check
#.\ipmitool.exe  -I lanplus -H 192.168.1.2 -U idrac -P PasswordHere raw 0x30 0xce 0x00 0x16 0x05 0x00 0x00 0x00 0x05 0x00 0x00 0x00 0x00 

function DisablePCICheck {
    param (
    )
    # disable pci check
    C:\ipmitool_1.8.18-dellemc_p001\ipmitool.exe -I lanplus -H 192.168.1.2 -U idrac -P PasswordHere raw 0x30 0xce 0x00 0x16 0x05 0x00 0x00 0x00 0x05 0x00 0x01 0x00 0x00
    # allow static fan speed
    C:\ipmitool_1.8.18-dellemc_p001\ipmitool.exe -I lanplus -H 192.168.1.2 -U idrac -P PasswordHere raw 0x30 0x30 0x01 0x00
}

# fan static speed to 10%
function SetFanTo10 {
    param (
    )
    C:\ipmitool_1.8.18-dellemc_p001\ipmitool.exe -I lanplus -H 192.168.1.2 -U idrac -P PasswordHere raw 0x30 0x30 0x02 0xff 0x0a
}

function SetFanTo15 {
    param (
    )
    C:\ipmitool_1.8.18-dellemc_p001\ipmitool.exe -I lanplus -H 192.168.1.2 -U idrac -P PasswordHere raw 0x30 0x30 0x02 0xff 0x0f
}
# fan static speed to 20%
function SetFanTo20 {
    param (
    )
    C:\ipmitool_1.8.18-dellemc_p001\ipmitool.exe -I lanplus -H 192.168.1.2 -U idrac -P PasswordHere raw 0x30 0x30 0x02 0xff 0x14
}
function SetFanTo25 {
    param (
    )
    C:\ipmitool_1.8.18-dellemc_p001\ipmitool.exe -I lanplus -H 192.168.1.2 -U idrac -P PasswordHere raw 0x30 0x30 0x02 0xff 0x19
}
function SetFanTo30 {
    param (
    )
    C:\ipmitool_1.8.18-dellemc_p001\ipmitool.exe -I lanplus -H 192.168.1.2 -U idrac -P PasswordHere raw 0x30 0x30 0x02 0xff 0x1e
}
function GetFanRPMs {
    param (
    )
    C:\ipmitool_1.8.18-dellemc_p001\ipmitool.exe  -I lanplus -H 192.168.1.2 -U idrac -P PasswordHere sensor reading  "Fan1 RPM" "Fan2 RPM" "Fan3 RPM"
}

function GetTemps {
    param (
    )
    # get current cpu temp in celsius
    $temps = C:\ipmitool_1.8.18-dellemc_p001\ipmitool.exe  -I lanplus -H 192.168.1.2 -U idrac -P PasswordHere sdr type temperature 
    # Use the Select-String cmdlet to find matches
    return $temps
}
function GetHighestTemp {
    param (
        $temps
    )
    $regexPattern = "(?<=\|\s)\d+(?=\sdegrees\sC)"
    $stringMatches = $temps | Select-String -Pattern $regexPattern -AllMatches
    # Extract matched values
    $highestTemp = $stringMatches.Matches.Value | Sort-Object -Descending | Select-Object -First 1
    return $highestTemp
}

DisablePCICheck
Clear-Host
while ($true) {
    $temps = GetTemps
    $highestTemp = GetHighestTemp -temps $temps
    if ($highestTemp -le 48){
        Write-Host "$(Get-Date -Format 'yyy-MM-dd hh:ss') - Highest temp is $highestTemp. Setting fan to 15%"
        SetFanTo15
    }
    if (($highestTemp -gt 49)-and ($highestTemp -lt 52)) {
        Write-Host "$(Get-Date -Format 'yyy-MM-dd hh:ss') - Highest temp is $highestTemp. Setting fan to 20%"
        SetFanTo20
    }
    if ($highestTemp -ge 52){
        Write-Host "$(Get-Date -Format 'yyy-MM-dd hh:ss') - Highest temp is $highestTemp. Setting fan to 25%"
        SetFanTo25
    }
    if ($highestTemp -ge 60){
        Write-Host "$(Get-Date -Format 'yyy-MM-dd hh:ss') - Highest temp is $highestTemp. Setting fan to 30%"
        SetFanTo30
    }
    Start-Sleep -Seconds 60
}
