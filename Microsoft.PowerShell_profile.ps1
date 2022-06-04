# bashify
# https://github.com/edoardottt/bashify
# edoardottt, https://www.edoardoottavianelli.it/

#
# This function modifies the prompt layout.
#
$foregroundColor = 'white'
$time = Get-Date
$psVersion= $host.Version.Major
$curUser= (Get-ChildItem Env:\USERNAME).Value
$curComp= (Get-ChildItem Env:\COMPUTERNAME).Value

Write-Host "Greetings, $curUser!" -foregroundColor $foregroundColor
Write-Host "It is: $($time.ToLongDateString())"
Write-Host "You're running PowerShell version: $psVersion" -foregroundColor Green
Write-Host "Your computer name is: $curComp" -foregroundColor Green
Write-Host "Happy scripting!" `n

function Prompt {
    $curtime = Get-Date
    Write-Host -NoNewLine "$" -foregroundColor Green
    Write-Host -NoNewLine "[" -foregroundColor Yellow
    Write-Host -NoNewLine ("{0}" -f (Get-Date)) -foregroundColor $foregroundColor
    Write-Host -NoNewLine "\" -foregroundColor Yellow
    Write-Host -NoNewLine (Get-Location | Foreach-Object { $_.Path }) -foregroundColor $foregroundColor
    Write-Host -NoNewLine "]" -foregroundColor Yellow
    Write-Host -NoNewLine ">" -foregroundColor Red
    $host.UI.RawUI.WindowTitle = "PS >> User: $curUser >> Current DIR: $((Get-Location).Path)"
    Return " "
}

#
# Alias l = ls
#
New-Alias -Name "l" -Value "ls"

#
# Alias c = clear
#
New-Alias -Name "c" -Value "clear"

# touch
# example: touch ciao.txt
#
function touch {
    $file = $args[0]
    if ( ($file -eq $null) -or ($file -eq "") )
    {
        Write-Output "usage: touch filename"
        return
    }
    New-Item -Path $args[0] -ItemType File
}

#
# uname
#
function uname {
    Get-CimInstance Win32_OperatingSystem | Select-Object 'Caption', 'CSName', 'Version', 'BuildType', 'OSArchitecture' | Format-Table -AutoSize
}

#
# cut
# cut filename separator column-number
# example: cut file.txt , 3 
function cut {
    $filename = $args[0]
    if ( ($filename -eq $null) -or ($filename -eq "") )
    {
        Write-Output "usage: cut filename separator column"
        Write-Output 'example: cut file.txt "," 3'
        return
    }
    $separator = $args[1]
    if ( ($separator -eq $null) -or ($separator -eq "") )
    {
        Write-Output "usage: cut filename separator column"
        Write-Output 'example: cut file.txt "," 3'
        return
    }
    $column = $args[2]
    if ( ($column -eq $null) -or ($column -eq "") )
    {
        Write-Output "usage: cut filename separator column"
        Write-Output 'example: cut file.txt "," 3'
        return
    }
    Get-Content $filename | ForEach-Object {
        $_.split($separator)[$column]
    }
}

# df
# source: https://gist.github.com/mweisel/3c357eba86ac6cae15b2
#
function df
{
    [CmdletBinding()]
    param 
    (
        [Parameter(Position=0,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [Alias('hostname')]
        [Alias('cn')]
        [string[]]$ComputerName = $env:COMPUTERNAME,
        
        [Parameter(Position=1,
                   Mandatory=$false)]
        [Alias('runas')]
        [System.Management.Automation.Credential()]$Credential =
        [System.Management.Automation.PSCredential]::Empty,
        
        [Parameter(Position=2)]
        [switch]$Format
    )
    
    BEGIN
    {
        function Format-HumanReadable 
        {
            param ($size)
            switch ($size) 
            {
                {$_ -ge 1PB}{"{0:#.#'P'}" -f ($size / 1PB); break}
                {$_ -ge 1TB}{"{0:#.#'T'}" -f ($size / 1TB); break}
                {$_ -ge 1GB}{"{0:#.#'G'}" -f ($size / 1GB); break}
                {$_ -ge 1MB}{"{0:#.#'M'}" -f ($size / 1MB); break}
                {$_ -ge 1KB}{"{0:#'K'}" -f ($size / 1KB); break}
                default {"{0}" -f ($size) + "B"}
            }
        }
        
        $wmiq = 'SELECT * FROM Win32_LogicalDisk WHERE Size != Null AND DriveType >= 2'
    }
    
    PROCESS
    {
        foreach ($computer in $ComputerName)
        {
            try
            {
                if ($computer -eq $env:COMPUTERNAME)
                {
                    $disks = Get-WmiObject -Query $wmiq `
                             -ComputerName $computer -ErrorAction Stop
                }
                else
                {
                    $disks = Get-WmiObject -Query $wmiq `
                             -ComputerName $computer -Credential $Credential `
                             -ErrorAction Stop
                }
                
                if ($Format)
                {
                    # Create array for $disk objects and then populate
                    $diskarray = @()
                    $disks | ForEach-Object { $diskarray += $_ }
                    
                    $diskarray | Select-Object @{n='Name';e={$_.SystemName}}, 
                        @{n='Vol';e={$_.DeviceID}},
                        @{n='Size';e={Format-HumanReadable $_.Size}},
                        @{n='Used';e={Format-HumanReadable `
                        (($_.Size)-($_.FreeSpace))}},
                        @{n='Avail';e={Format-HumanReadable $_.FreeSpace}},
                        @{n='Use%';e={[int](((($_.Size)-($_.FreeSpace))`
                        /($_.Size) * 100))}},
                        @{n='FS';e={$_.FileSystem}},
                        @{n='Type';e={$_.Description}}
                }
                else 
                {
                    foreach ($disk in $disks)
                    {
                        $diskprops = @{'Volume'=$disk.DeviceID;
                                   'Size'=$disk.Size;
                                   'Used'=($disk.Size - $disk.FreeSpace);
                                   'Available'=$disk.FreeSpace;
                                   'FileSystem'=$disk.FileSystem;
                                   'Type'=$disk.Description
                                   'Computer'=$disk.SystemName;}
                    
                        # Create custom PS object and apply type
                        $diskobj = New-Object -TypeName PSObject `
                                   -Property $diskprops
                        $diskobj.PSObject.TypeNames.Insert(0,'BinaryNature.DiskFree')
                    
                        Write-Output $diskobj
                    }
                }
            }
            catch 
            {
                # Check for common DCOM errors and display "friendly" output
                switch ($_)
                {
                    { $_.Exception.ErrorCode -eq 0x800706ba } `
                        { $err = 'Unavailable (Host Offline or Firewall)'; 
                            break; }
                    { $_.CategoryInfo.Reason -eq 'UnauthorizedAccessException' } `
                        { $err = 'Access denied (Check User Permissions)'; 
                            break; }
                    default { $err = $_.Exception.Message }
                }
                Write-Warning "$computer - $err"
            } 
        }
    }
    
    END {}
}

# head
# usage: head filename count (default 10)
# example: head ciao.txt 30
#
function head {
    $filename = $args[0]
    if ( ($filename -eq $null) -or ($filename -eq "") )
    {
        Write-Output "usage: head filename count (default 10)"
        Write-Output 'example: head ciao.txt 30'
        return
    }
    $count = $args[1]
    if ( ($count -eq $null) -or ($count -eq "") -or ([int]$count -lt 1) )
    {
        $count = 10
    }
    Get-Content $filename | select -first $count
}

# tail
# usage: tail filename count (default 10)
# example: tail ciao.txt 30
#
function tail {
    $filename = $args[0]
    if ( ($filename -eq $null) -or ($filename -eq "") )
    {
        Write-Output "usage: tail filename count (default 10)"
        Write-Output 'example: tail ciao.txt 30'
        return
    }
    $count = $args[1]
    if ( ($count -eq $null) -or ($count -eq "") -or ([int]$count -lt 1) )
    {
        $count = 10
    }
    Get-Content -Tail $count $filename
}

# zip
# usage: zip input output (output by default is input.zip)
# the input can be a folder or a file, the output is the zip filename.
# example: zip ciao.txt compressed (this will output compressed.zip)
function zip {
    $filename = $args[0]
    if ( ($filename -eq $null) -or ($filename -eq "") )
    {
        Write-Output "usage: zip input output (output by default is input.zip)"
        Write-Output 'the input can be a folder or a file, the output is the zip filename'
        Write-Output "example: zip ciao.txt compressed (this will output compressed.zip)"
        return
    }
    $output = $args[1]
    if ( ($output -eq $null) -or ($output -eq "") )
    {
        $output = $filename
    }
    $output = $output + ".zip"
    
    Compress-Archive -Path $filename -DestinationPath $output
}

# unzip
# usage: unzip input output
# the input is the zip filename, the output is the name of the output folder.
# example: unzip compressed.zip original
function unzip {
    $filename = $args[0]
    if ( ($filename -eq $null) -or ($filename -eq "") )
    {
        Write-Output "usage: unzip input output"
        Write-Output 'the input is the zip filename, the output is the name of the output folder'
        Write-Output "example: unzip compressed.zip original"
        return
    }
    $output = $args[1]
    if ( ($output -eq $null) -or ($output -eq "") )
    {
        Write-Output "usage: unzip input output"
        Write-Output 'the input is the zip filename, the output is the name of the output folder'
        Write-Output "example: unzip compressed.zip original"
        return
    }
    
    Expand-Archive -Path $filename -DestinationPath $output
}

# top
# usage: top <lines> (default lines: 30)
# The parameter 'lines' is not mandatory. 
# example: top 15
function top {
    $count = $args[0]
    if ( ($count -eq $null) -or ($count -eq "") -or ([int]$count -lt 1) )
    {
        $count = 30
    }
    while (1) { ps | sort -desc cpu | select -first $count; sleep -seconds 2; cls }
}
