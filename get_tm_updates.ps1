<#	
	.NOTES
	===========================================================================
	 Created on:   	24/01/2021
	 Created by:   	François Ribière
	 Organization: 	na
	 Filename:     	Get_TM_Updates.ps1
	===========================================================================
	.DESCRIPTION
		This script is charged to download entirely the antivirus updates for 
		Trend Micro OfficeScan/Apex One.
		Charged to user to 
		This script is using proxies from Windows settings, w/o password. It must 
		be run with admin access to do it. Without proxy, a classic user can run it.
		If you are behind a proxy download files
#>


using namespace System.Net.Http

##### PARAMETRES #####

Param(
        [Parameter(Mandatory = $false)]
        [string]$output_dir
)

# Source file location
$srcurl = "http://osce14-p.activeupdate.trendmicro.com/activeupdate"
$sourceIniSig  = "$srcurl/server.ini"

if (!$output_dir) {
	$dirpath = (Split-Path ((Get-Variable MyInvocation -Scope Script).Value).MyCommand.Path)
	$output_dir = "$dirpath\updates"
}

New-Item -Path $output_dir  -ItemType Directory  -erroraction 'silentlycontinue'



##### FONCTIONS #####

function downloadfile {
	param (
		[string]$url,
		[string]$file,
		[System.Net.WebClient]$WebClient)	

	$sigfile = $file -replace ".zip",".sig"
	$sigurl  = $url  -replace ".zip",".sig"

	if (Test-Path "$file") { Remove-Item "$file" }
	if (Test-Path "$sigfile") { Remove-Item "$sigfile" }

	if (!$WebClient) {
		Invoke-WebRequest -Uri "$url" -OutFile "$file"
		Invoke-WebRequest -Uri "$sigurl" -OutFile "$sigfile"
	}
	else {
		$WebClient.DownloadFile($url,$file)
		$WebClient.DownloadFile($sigurl,$sigfile)
	}
}

function ouvertureProxy {
	$isDefined = Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' | Select-Object ProxyEnable

	if ($isDefined -eq 1) {
		$ProxyServer = Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' | Select-Object ProxyServer

	# get credentials
		$WebClient = New-Object System.Net.WebClient
		$WebProxy  = New-Object System.Net.WebProxy($ProxyServer,$true) 
		$WebClient.Proxy = $WebProxy
		#$WebClient.Proxy.Credentials = Get-Credential

		# Now download file with $WebClient.DownloadFile($source,$dest)
		return $WebClient
	}
	return $null
}


#####  TRAITEMENT #####

# gestion proxy (contrôle et ouverture flux si défini), Null ou de type System.Net.WebClient
$WebClient = ouvertureProxy

### Récupération du fichier des listes de signatures 
# Fichier temporaire 
$tempFileIniSig =  $(New-TemporaryFile).FullName
downloadfile "$sourceIniSig" "$tempFileIniSig" $WebClient


### Parcours du fichier de liste des signatures, et téléchargement (répertoire + zip + sha)

Select-String -Path "$tempFileIniSig" -Pattern "pattern" | select-string -Pattern "zip" | foreach-Object {
	$zip = (($_ -split "=")[1] -split ",")[0]
	$outfile = "$output_dir/$zip" -replace "/","\"

	$pathzip = Split-Path $zip
	$createpath = "$pathzip"  -replace "/","\"

	New-Item -Path "$output_dir\$createpath" -ItemType Directory -erroraction 'silentlycontinue'

	if (Test-Path "$outfile") { Remove-Item "$outfile" }
	downloadfile "$srcurl/$zip" "$outfile" $WebClient
}

# Restriction aux fichiers de langue anglaise (sinon, to)
Select-String -Path "$tempFileIniSig" -Pattern "path" | select-string -Pattern "zip" | select-string -Pattern "enu" | foreach-Object {
	$zip = (($_ -split "=")[1] -split ",")[0]
	$outfile = "$output_dir/$zip" -replace "/","\"

	$pathzip = Split-Path $zip
	$createpath = "$pathzip"  -replace "/","\"

	New-Item -Path "$output_dir\$createpath" -ItemType Directory -erroraction 'silentlycontinue'

	if (Test-Path "$outfile") { Remove-Item "$outfile" }
	downloadfile "$srcurl/$zip" "$outfile" $WebClient
}

# Restriction aux fichiers de langue anglaise (sinon, to)
Select-String -Path "$tempFileIniSig" -Pattern "path" | select-string -Pattern "zip" | select-string -Pattern "fra" | foreach-Object {
	$zip = (($_ -split "=")[1] -split ",")[0]
	$outfile = "$output_dir/$zip" -replace "/","\"

	$pathzip = Split-Path $zip
	$createpath = "$pathzip"  -replace "/","\"

	New-Item -Path "$output_dir\$createpath" -ItemType Directory -erroraction 'silentlycontinue'

	if (Test-Path "$outfile") { Remove-Item "$outfile" }
	downloadfile "$srcurl/$zip" "$outfile" $WebClient
}

Select-String -Path "$tempFileIniSig" -Pattern "engine" | select-string -Pattern "zip" | foreach-Object {
	$zip = (($_ -split "=")[1] -split ",")[1]
	$outfile = "$output_dir/$zip" -replace "/","\"

	$pathzip = Split-Path $zip
	$createpath = "$pathzip"  -replace "/","\"

	New-Item -Path "$output_dir\$createpath" -ItemType Directory -erroraction 'silentlycontinue'

	if (Test-Path "$outfile") { Remove-Item "$outfile" }
	downloadfile "$srcurl/$zip" "$outfile" $WebClient
}

#####  FIN #####