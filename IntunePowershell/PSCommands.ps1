#========================================================================
# Date: 21-01-2017
# Author: Bert van Duijn
#========================================================================

$PSCommands = "PSCommands.xml"
##$Script:ParentFolder = Split-Path (Get-Variable MyInvocation -scope 1 -ValueOnly).MyCommand.Definition
$XMLFile = Join-Path (convert-path .) $PSCommands

if(!(Test-Path $XMLFile)){
	Write-EventLog -LogName Application -Source "Application Management" -EventId 1000 -EntryType Error -Message "Command file $PSCommands not detected in folder $($ParentFolder)."; Exit
  } else{
	[XML]$Script:PSXML = Get-Content $PSCommands
}


Foreach ($cmd in $PSXML.Commands.Command) { 
	if (($cmd.file.FilePath) -and ($cmd.scriptblock)) {
		Write-EventLog -LogName Application -Source "Application Management" -EventId 1000 -EntryType Error -Message "ScriptFile and Script-Block detected in Command file $($PSCommands)."
		Exit
	}else{
		cd $cmd.workingdir
		if (($cmd.file.FilePath) -and (!$cmd.scriptblock)) {
			Write-EventLog -LogName Application -Source "Application Management" -EventId 1000 -EntryType Information -Message "Start Running ScriptFile $($cmd.file.FilePath) $($cmd.file.args)."
			try {Invoke-expression $cmd.file.FilePath $cmd.file.args}
			  catch{Write-EventLog -LogName Application -Source "Application Management" -EventId 1000 -EntryType Error -Message "Error Running ScriptFile $($cmd.file.FilePath) $($cmd.file.args)."; Exit}
			
		} elseif ((!$cmd.file.FilePath) -and ($cmd.scriptblock)) {
			Write-EventLog -LogName Application -Source "Application Management" -EventId 1000 -EntryType Information -Message "Start Running Script-Block $($cmd.scriptblock)."
			try {Invoke-expression $cmd.scriptblock}
			  catch{Write-EventLog -LogName Application -Source "Application Management" -EventId 1000 -EntryType Error -Message "Error Running Script-Block $($cmd.scriptblock)."; Exit}
		}
	}
}
Write-EventLog -LogName Application -Source "Application Management" -EventId 1000 -EntryType Information -Message "Finished Running $($PSXML.Commands.Application.Name)"
