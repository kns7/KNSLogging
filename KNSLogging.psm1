#########################################################################################
# KNS Logging Module
# 
# Copyright 2018, Nicolas Kapfer
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
# and associated documentation files (the "Software"), to deal in the Software without restriction, 
# including without limitation the rights to use, copy, modify, merge, publish, distribute, 
# sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all copies or 
# substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING 
# BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#########################################################################################
Function Initialize-Log {
    <#
    .SYNOPSIS
    Init log File.
    .DESCRIPTION
    This function must be called initially to create the log file and set the internal variable "Path"
    If the file already exists, it will be deleted and created new. 

    .PARAMETER LogFile
    System.String the path to the log file. 
    .PARAMETER OutOnConsole
    System.Boolean Set for the whole module if the Log functions (Write-Log and Event-Log) should be outputted into the Console
    .EXAMPLE   
    Initialize-Log -LogFile "C:\Logs\Test.log"
    #>
    Param 
    (
        [Parameter(Mandatory=$true)]
        [String]$LogFile,
        [Parameter(Mandatory=$False)]
        [Boolean]$OutOnConsole=$False
    )
    if ((Test-Path $LogFile)){
        # The file already exists, remove it
        Remove-Item -Path $LogFile -Force
        }
    
        # The file doesn't exist or has been removed, create it
        $NewLogFile = New-Item $LogFile -Force -ItemType File
    
        # Set Script Path as Module Variable
        $Script:Path = $LogFile
        $Script:OutOnConsole = $OutOnConsole

        Write-Log -Message "Init Logfile done" -Level "INFO" -OutOnConsole $Script:OutOnConsole
}

Function Write-Log { 
    <# 
    .Synopsis 
       Write-Log writes a message to a specified log file with the current time stamp. 
    .DESCRIPTION 
       The Write-Log function is designed to add logging capability to other scripts. 
       In addition to writing output and/or verbose you can write to a log file for 
       later debugging. 
     
       By default the function will create the path and file if it does not  
       exist.  
     
    .PARAMETER Message
        System.String The Content to write in Logfile

    .PARAMETER Level
        System.String The Log Level. Valid values are ERROR,WARN and INFO

    .PARAMETER OutOnConsole
    System.Boolean If set to True, the log will also appear in the console. Default set to False
        
    .EXAMPLE 
       Write-Log -Message "Log message"  
       Writes the message to c:\Logs\PowerShellLog.log 
    .EXAMPLE 
       Write-Log -Message "Restarting Server" -Path c:\Logs\Scriptoutput.log 
       Writes the content to the specified log file and creates the path and file specified.  
    .EXAMPLE 
       Write-Log -Message "Does not exist" -Path c:\Logs\Script.log -Level Error 
       Writes the message to the specified log file as an error message, and writes the message to the error pipeline. 
    #> 
    [CmdletBinding()] 
    [Alias('wl')] 
    [OutputType([int])] 
    Param 
    ( 
        # The string to be written to the log. 
        [Parameter(Mandatory=$true, 
                    ValueFromPipelineByPropertyName=$true, 
                    Position=0)] 
        [ValidateNotNullOrEmpty()] 
        [Alias("LogContent")] 
        [string]$Message,
    
        [Parameter(Mandatory=$false, 
                    ValueFromPipelineByPropertyName=$true, 
                    Position=2)] 
        [ValidateSet("Error","Warn","Info")] 
        [string]$Level="Info",
        
        # Write Log-Content to Console. 
        [Parameter(Mandatory=$false, 
                    ValueFromPipelineByPropertyName=$true, 
                    Position=3)] 
        [Alias('Console')] 
        [boolean]$OutOnConsole=$Script:OutOnConsole
        
    )
    
    # If attempting to write to a log file in a folder/path that doesn't exist 
    # to create the file include path. 
    if (!(Test-Path $Script:Path)) {
        Write-Verbose "Creating $Script:Path." 
        $NewLogFile = New-Item $Script:Path -Force -ItemType File
    }

    # Now do the logging and additional output based on $Level     
    $LogLine = "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | "
        
    Switch ($level) {
        
        'Error' {$LogLine += "ERROR   |"}
        'Warn' { $LogLine += "WARNING |"}
        'Info' { $LogLine += "INFO    |"}
            
    } 
              
    if($Message -eq ""){ $LogLine = " " }else{ $LogLine += " $Message" }  

    if($OutOnConsole) {Write-Host "$LogLine"} 
    Write-Output "$LogLine" | Out-File -FilePath $Script:Path -Append               
}

function Write-EventLog{
    <#
    .SYNOPSIS
    Write a new entry in Event Log
    .DESCRIPTION
    This function write a new entry in Windows Event Log. It needs a Source and Message. Per default, the Level is set to Information
    .PARAMETER Source
    System.String. Required. The Source of the Event. 
    .PARAMETER Message
    System.String. Required. The Message to put into Event log. 
    .PARAMETER Level
    System.String. Optional. The Event Level. Valid Values are "Error", "Warning", "Information", "SuccessAudit" and "FailureAudit". Default value is "Information"
    .EXAMPLE
    Write-EventLog -Source "ActiveDirectory" -Message "Everything's fine! Let's set back and relax"
    #>
    Param(
        [Parameter(
            Mandatory=$true,
            ParameterSetName = '',
            ValueFromPipeline = $false)]
            [string]$Source,
        [Parameter(
            Mandatory=$true,
            ParameterSetName = '',
            ValueFromPipeline = $false)]
            [string]$Message,
        [Parameter(
            Mandatory=$false,
            ParameterSetName = '',
            ValueFromPipeline = $false)]
            [ValidateSet("Error", "Warning", "Information", "SuccessAudit", "FailureAudit")]
            [string]$Level="Information"
    )
    Begin{

    }
    Process{
        Write-Eventlog -logname Application -source $Source -entrytype $Level -message $Message
        if($Script:OutOnConsole){
            Write-Host "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") | $($Level) - [EVENT] $($Source) - $($Message)"
        }
    }
    End{

    }
}

Function Rotate-Files {
    <#     
    .SYNOPSIS
    Clean up and rotate files
    
    .DESCRIPTION
    This script rotates files and keeps them in three directories
    \daily
    \weekly
    \monthly
    
    New files are expected to be written to $FilesDir and Rotate-Files moves them into subdirectories
    
    .EXAMPLE
    Rotate-Logs -FilesDir "c:\MyFilesDirectory"
    #>
    
    Param (
    [Parameter(Mandatory=$True,ValueFromPipeline=$false)]
    [string]$FilesDir, # Directory log files are written to
    [Parameter(ValueFromPipeline=$false)]
    [int]$DayOfWeek = 2, # The day of the week to store for weekly files (1 to 7 where 1 is Sunday)
    [Parameter(ValueFromPipeline=$false)]
    [int]$DayOfMonth = 1, # The day of the month to store for monthly files (Max = 28 since varying last day of month not currently handled)
    [Parameter(ValueFromPipeline=$false)]
    [int]$RotationDaily = 7, # The number of daily files to keep
    [Parameter(ValueFromPipeline=$false)]
    [int]$RotationWeekly = 6, # The number of weekly files to keep
    [Parameter(ValueFromPipeline=$false)]
    [int]$RotationMonthly = 5 # The number of monthly files to keep
    )
    
    Process {
    if (-not $FilesDir) {
        Write-Host "Error:  -FilesDir not set"
        Exit
        }
    
        $date = Get-Date
    
        $verify_log_dir = Test-Path $FilesDir
        if ($verify_log_dir) {
            $verify_daily_dir = Test-Path "$FilesDir\daily"
            $verify_weekly_dir = Test-Path "$FilesDir\weekly"
            $verify_monthly_dir = Test-Path "$FilesDir\monthly"
    
            # If the daily directory does not exist try to create it
            if (!$verify_daily_dir) {
                $md_daily = md -Name "daily" -Path $FilesDir
                if (!$md_daily){
                    Write-Host "Error setting up Directories. Check Permissions."
                    exit
                }
            }
            # If the weekly directory does not exist try to create it
            if (!$verify_weekly_dir) {
                $md_weekly = md -Name "weekly" -Path $FilesDir
                if (!$md_weekly){
                    Write-Host "Error setting up Directories. Check Permissions."
                    exit
                }
            }
            # If the monthly directory does not exist try to create it
            if (!$verify_monthly_dir) {
                $md_monthly = md -Name "monthly" -Path $FilesDir
                if (!$md_monthly){
                    Write-Host "Error setting up Directories. Check Permissions."
                    exit
                }
            }
        }
        else {
            Write-Host "Error:  Directory $FilesDir does not exist."
            exit
        }
    
        $logs_root = Get-ChildItem $FilesDir | where {$_.Attributes -ne "Directory"}
    
        if ($logs_root) {
            foreach ($file in $logs_root) {
                $file_date = get-date $file.LastWriteTime
                if ($file_date -ge $date.AddDays(-$RotationDaily)) {
                    #Write-Host "$($file.Name) - $($file_date)"
                    Copy-Item "$FilesDir\$file" "$FilesDir\daily"
                }
                if ($file_date -ge $date.AddDays(-$RotationWeekly*7) -and [int]$file_date.DayOfWeek -eq $DayOfWeek) {
                    #Write-Host "Weekly $($file.Name) - $($file_date)"
                    Copy-Item "$FilesDir\$file" "$FilesDir\weekly"
                }
                if ($file_date -ge $date.AddDays(-$RotationMonthly*30) -and [int]$file_date.Day -eq $DayOfMonth) {
                    #Write-Host "Monthly $($file.Name) - $($file_date) $([int]$file_date.DayOfWeek)"
                    Copy-Item "$FilesDir\$file" "$FilesDir\monthly"
                }
                Remove-Item "$FilesDir\$file"
            }
    
            $logs_daily = Get-ChildItem "$FilesDir\daily" | where {$_.Attributes -ne "Directory"} | Sort-Object LastWriteTime -Descending
            $logs_weekly = Get-ChildItem "$FilesDir\weekly" | where {$_.Attributes -ne "Directory"}
            $logs_monthly = Get-ChildItem "$FilesDir\monthly" | where {$_.Attributes -ne "Directory"}
    
            if ($logs_daily) {
                foreach ($file in $logs_daily) {
                    $file_date = get-date $file.LastWriteTime
                    if ($file_date -le $date.AddDays(-$RotationDaily)) {
                        #Write-Host "$file.Name"
                        Remove-Item "$FilesDir\daily\$file"                    
                    }
                }
            }
    
            if ($logs_weekly) {
                foreach ($file in $logs_weekly) {
                    $file_date = get-date $file.LastWriteTime
                    if ($file_date -le $date.AddDays(-$RotationWeekly*7)) {
                        #Write-Host "$file.Name"
                        Remove-Item "$FilesDir\weekly\$file"
                    }
                }
            }
    
            if ($logs_monthly) {
                foreach ($file in $logs_monthly) {
                    $file_date = get-date $file.LastWriteTime
                    if ($file_date -le $date.AddDays(-$RotationMonthly*30)) {
                        #Write-Host "$file.Name"
                        Remove-Item "$FilesDir\monthly\$file"
                    }
                }
            }
        }
    }
}