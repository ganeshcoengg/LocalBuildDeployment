# Parameter help description
Param(
    [parameter(Mandatory=$true)]
    [String] $BuildVersion,
    [parameter(Mandatory=$true)]
    [String] $CustomerName
)

try{
    $JsonData = (Get-Content ".\config.json" | Out-String)
    $JsonObject = ConvertFrom-Json -InputObject $JsonData -ErrorAction Stop
}
catch{
    Write-Host "Please check Json file parameters." -ForegroundColor Red
    Read-Host "Enter any key to exit"
    Exit
}
$logpath = $JsonObject.BuildLogsPath.Path
$logfile = $logpath+((Get-Date).ToString('yyyyMMdd'))+'_BuildDeploymentLogs.txt'
function LogWrite {
    param (
        [String]$logString,
        [bool] $iserror = $false
    )

    $time = Get-Date

    if($iserror){
        $string = '*** ' +$time.ToString() +' == ERROR == '+ $logString
    }
    else{
        $string = '*** ' +$time.ToString() +' == '+ $logString
    }
    Add-Content $logfile -Value $string
}
function LogWrite_WF {
    param ([String]$logString)
    $string = '       '+ $logString
    Add-Content $logfile -Value $string
    Add-Content $logfile ""
}

LogWrite "******************* SUMMARY *******************"
# Map tfs-server/GITBUILD directory to validate the Build Version and Cutomer Name
New-PSDrive -Name 'Q' -PSProvider 'FileSystem' -Root '\\tfs-server\GITBUILDS\OB01-ERP\'
$tfs_buildpath = 'Q:\' + $BuildVersion
#Check the Entered build version avilable in tfs-server or not
if(Test-path -Path $tfs_buildpath){
    $pathofcustomerScript = $tfs_buildpath + '\_PublishedWebsites\in-mvc-20\App_Data\Admin\OfficeBOX\'
    $customerlist = Get-ChildItem -Path $pathofcustomerScript | Where-Object { $_.PSIsContainer }
    # Check the Entered Customer Name is valide or not
    if($customerlist.Name -contains $CustomerName){
        Write-Host "Customer Name -->  $CustomerName, Build Version -->" $BuildVersion -ForegroundColor Magenta
        LogWrite "Customer Name -->  $CustomerName, Build Version --> $BuildVersion"
    }
    # OB is to Skip the Customer name, if you do not want to deplloye with customer specific build
    elseif($CustomerName.ToUpper() -eq "DEV"){
        Write-Host 'You have chosen to deploye build without executing customer specific Script' -ForegroundColor Yellow
        LogWrite 'You have chosen to deploye build without executing customer specific Script'
    }
    else{
        Write-Host "Please enter the valide customer Name from List ==> " -ForegroundColor Red
        LogWrite "Please enter the valide customer Name from List ==> $customerlist" $true
        Write-Host `n$customerlist
        Remove-PSDrive -Name 'Q'
        Exit        #Exit as the input is invalid
    }
}
else{
    Write-Host "Build Version $BuildVersion not present in tfs-server" -ForegroundColor Red
    LogWrite "Build Version $BuildVersion not present in tfs-server" $true
    Remove-PSDrive -Name 'Q'
    Exit        #Exit as the input is invalid
}

#Remove the maped PSDrive 
Remove-PSDrive -Name 'Q' 

$response = Read-Host "`n Would you like to Continue? (Y/N)"
if($response.ToUpper() -eq "Y"){
    # Web Site Stoping 
    Write-Host "`n`t ************************ IIS STOPING ************************ `n"
    LogWrite " ************************ IIS STOPING ************************ "
    .\WebSite_Start_Stop.ps1 'STOP'

    # Backup process started
    .\CreateAndCopy.ps1 $BuildVersion $CustomerName
}
else {
    Write-Host "`tWe Are Exiting. Thank you!" -ForegroundColor Magenta
    LogWrite "You have Terminated the Execution"
    Start-Sleep 3
    Exit
}
