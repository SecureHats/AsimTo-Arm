<#
    Title:          AsimTo-ARM Converter
    Language:       PowerShell
    Version:        1.0
    Author:         Rogier Dijkman
    Last Modified:  21/08/2023

    DESCRIPTION
    This GitHub action is used to convert ASIM parser files to deployable ARM templates.
#>

param (
    [Parameter(Mandatory = $true)]
    [System.IO.FileInfo]$FilesPath = '.',

    [Parameter(Mandatory = $true)]
    [System.IO.FileInfo]$outputFolder = '',

    [Parameter(Mandatory = $false)]
    [string]$returnObject = 'false'
        
)

try {
    Write-Verbose "Importing Helper Module"
    Import-Module "$($PSScriptRoot)/modules/HelperFunctions.psm1"
} catch {
    Write-Error $_.Exception.Message
    break
}

$hashTable = @{
    FilesPath      = $FilesPath
    OutputFolder   = $OutputFolder
    ReturnObject   = [System.Convert]::ToBoolean($ReturnObject)
}

Convert-AsimToArm @hashTable
