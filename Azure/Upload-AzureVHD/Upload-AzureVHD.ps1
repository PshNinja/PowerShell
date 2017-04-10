<#
	SYNOPSIS
		A script to upload a custom OS Image vhd file to Azure
	DESCRIPTION
		This script will upload the specified vhd file to Azure to the
        specified URL or to the default image blob url. 
	PARAMETER ImagePath
		The path of a custom OS image vhd file.
	PARAMETER subscriptionID
		ID of the destination Azure Subscription
    PARAMETER ResourceGroupName
        Name of the destination ResourceGroup
    PARAMETER DestUrl
        Url of the image destination
	EXAMPLE
	    .\Upload-AzureVHD.ps1 -subscriptionId '3c7b4ca9-8975-4f91-a986-23123f495c8a'
		Description
		-----------
		This will invoke the Upload-AzureVHD.ps1 script with a specified subscriptionID.
        User will be prompted for the other variables.
        
        .\Upload-AzureVHD.ps1
        Description
        -----------
        User will be prompted for all variables.
	NOTES
		ScriptName	:	Upload-AzureVHD.ps1
		Created By	:	PSH Ninja
		Date Coded	:	11/11/2016
		Last Rev	:	3/27/2017
		
#>
Param (
    [string]$ImagePath,
    [string]$subscriptionId,
    [string]$ResourceGroupName,
    [string]$DestUrl

)

Process {

Function Get-VhdPath($initialDirectory)
{
 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.filter = "Virtual Hard Disk (*.vhd)| *.vhd"
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
} #end function Get-VhdPath


# Sign-in with Azure account credentials
Login-AzureRmAccount -ErrorAction Stop

# Select Azure Subscription
if(!($subscriptionID)){$subscriptionId = (Get-AzureRmSubscription | Out-GridView -Title "Select an Azure Subscription ..." -PassThru).SubscriptionId}
Select-AzureRmSubscription -SubscriptionId $subscriptionId -ErrorAction Stop

# Select Azure Resource Group 
if (!($ResourceGroupName)){$ResourceGroupName = (Get-AzureRmResourceGroup | Out-GridView -Title "Select an Azure Resource Group ..." -PassThru).ResourceGroupName}

if (!($ImagePath)) {$ImagePath = Get-VhdPath -initialDirectory "C:"}

#Prompt for VHD name and source path
#[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
$targetVHDName = Split-Path $ImagePath -leaf

# Select Azure Storage account
if (!($DestUrl)){$DestUrl = "http://" + (Get-AzureRMStorageAccount | Out-GridView -Title "Select an Azure Storage Account..." -PassThru).StorageAccountName + ".blob.core.windows.net/system/Microsoft.Compute/Images/templates/" + $targetVHDName}

# Upload Azure vhd
Add-AzureRmVhd -ResourceGroupName $ResourceGroupName -Destination $DestUrl -LocalFilePath $ImagePath
}