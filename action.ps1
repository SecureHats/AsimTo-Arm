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
    [string]$FilesPath = '.',

    [Parameter(Mandatory = $true)]
    [string]$OutputPath = '.',

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
    FilesPath    = $FilesPath
    OutputPath   = $OutputPath
    ReturnObject = [System.Convert]::ToBoolean($ReturnObject)
}

Convert-AsimToArm @hashTable
