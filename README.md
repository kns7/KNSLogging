

# KNSLogging

## Description

This Powershell module provide helpers functions for logging. 
It can manage a Log file or write to the Event Log.

## List of CMDlets
### Initialize-Log
#### Synopsis
Init log File.
#### Syntax
```powershell
Initialize-Log [-LogFile] <String> [<CommonParameters>]
```
#### Parameters
| Name  | Alias  | Description | Required? | Pipeline Input | Default Value |
| - | - | - | - | - | - |
| <nobr>LogFile</nobr> |  | System.String the path to the log file. | true | false |  |
| <nobr>OutOnConsole</nobr> |  | System.Boolean Set for the whole module if the Log functions (Write-Log and Event-Log) should be outputted into the Console. | false | false |  |
#### Examples

**BEISPIEL 1**
```powershell
Initialize-Log -LogFile "C:\Logs\Test.log"
```

### Rotate-Files
#### Synopsis
Clean up and rotate files
#### Syntax
```powershell
Rotate-Files [-FilesDir] <String> [[-DayOfWeek] <Int32>] [[-DayOfMonth] <Int32>] [[-RotationDaily] <Int32>]
[[-RotationWeekly] <Int32>] [[-RotationMonthly] <Int32>] [<CommonParameters>]
```
#### Parameters
| Name  | Alias  | Description | Required? | Pipeline Input | Default Value |
| - | - | - | - | - | - |
| <nobr>FilesDir</nobr> |  |  | true | false |  |
| <nobr>DayOfWeek</nobr> |  | Directory log files are written to | false | false | 2 |
| <nobr>DayOfMonth</nobr> |  | The day of the week to store for weekly files \(1 to 7 where 1 is Sunday\) | false | false | 1 |
| <nobr>RotationDaily</nobr> |  | The day of the month to store for monthly files \(Max = 28 since varying last day of month not currently handled\) | false | false | 7 |
| <nobr>RotationWeekly</nobr> |  | The number of daily files to keep | false | false | 6 |
| <nobr>RotationMonthly</nobr> |  | The number of weekly files to keep The number of monthly files to keep | false | false | 5 |
#### Examples

**BEISPIEL 1**
```powershell
Rotate-Logs -FilesDir "c:\MyFilesDirectory"
```

### Write-EventLog
#### Synopsis
Write a new entry in Event Log
#### Syntax
```powershell
Write-EventLog [-Source] <String> [-Message] <String> [[-Level] <String>] [<CommonParameters>]
```
#### Parameters
| Name  | Alias  | Description | Required? | Pipeline Input | Default Value |
| - | - | - | - | - | - |
| <nobr>Source</nobr> |  | System.String. Required. The Source of the Event. | true | false |  |
| <nobr>Message</nobr> |  | System.String. Required. The Message to put into Event log. | true | false |  |
| <nobr>Level</nobr> |  | System.String. Optional. The Event Level. Valid Values are "Error", "Warning", "Information", "SuccessAudit" and "FailureAudit". Default value is "Information" | false | false | Information |
#### Examples

**BEISPIEL 1**
```powershell
Write-EventLog -Source "ActiveDirectory" -Message "Everything's fine! Let's set back and relax"
```

### Write-EventLog
#### Syntax
```powershell
Write-EventLog [-LogName] <string> [-Source] <string> [-EventId] <int> [[-EntryType] <EventLogEntryType>] [-Message] <string> [-Category <int16>] [-RawData <byte[]>] [-ComputerName <string>] [<CommonParameters>]
```
#### Parameters
| Name  | Alias  | Description | Required? | Pipeline Input | Default Value |
| - | - | - | - | - | - |
| <nobr>Category</nobr> | Keine |  | false | false |  |
| <nobr>ComputerName</nobr> | CN |  | false | false |  |
| <nobr>EntryType</nobr> | ET |  | false | false |  |
| <nobr>EventId</nobr> | ID, EID |  | true | false |  |
| <nobr>LogName</nobr> | LN |  | true | false |  |
| <nobr>Message</nobr> | MSG |  | true | false |  |
| <nobr>RawData</nobr> | RD |  | false | false |  |
| <nobr>Source</nobr> | SRC |  | true | false |  |
#### Links

 - [https://go.microsoft.com/fwlink/?LinkID=135281](https://go.microsoft.com/fwlink/?LinkID=135281)
### Write-Log
#### Syntax
```powershell
Write-Log writes a message to a specified log file with the current time stamp.
```
#### Parameters
| Name  | Alias  | Description | Required? | Pipeline Input | Default Value |
| - | - | - | - | - | - |
| <nobr>Message</nobr> | LogContent | System.String The Content to write in Logfile | true | true \(ByPropertyName\) |  |
| <nobr>Level</nobr> |  | System.String The Log Level. Valid values are ERROR,WARN and INFO | false | true \(ByPropertyName\) | Info |
| <nobr>OutOnConsole</nobr> | Console | System.Boolean If set to True, the log will also appear in the console. Default set to False | false | true \(ByPropertyName\) | False |
| <nobr>NoClobber</nobr> |  | NoClobber | false | false | False |
#### Outputs
 - System.Int32
#### Examples

**BEISPIEL 1**
```powershell
Write-Log -Message "Log message"
```
Writes the message to c:\\Logs\\PowerShellLog.log

**BEISPIEL 2**
```powershell
Write-Log -Message "Restarting Server" -Path c:\Logs\Scriptoutput.log
```
Writes the content to the specified log file and creates the path and file specified.

**BEISPIEL 3**
```powershell
Write-Log -Message "Does not exist" -Path c:\Logs\Script.log -Level Error
```
Writes the message to the specified log file as an error message, and writes the message to the error pipeline.

