function Convert-YamlToArm {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo]$FilesPath,

        [Parameter(Mandatory = $true)]
        [System.IO.FileInfo]$OutputFolder,

        [Parameter(Mandatory = $false)]
        [switch]$ReturnObject  
    )
    
    if ($OutputFolder) {
        if (Test-Path $OutputFolder) {
            $expPath = (Get-Item $OutputFolder).FullName
        }
        else {
            try {
                $script:expPath = (New-Item -Path $OutputFolder -ItemType Directory -Force).FullName
            }
            catch {
                Write-Error $file.Exception.Message
                break
            }
        }
    }
    
    #Region Fetching Parser Files
    try {
        $content = Get-ChildItem -Path $Path -Include "*.csl", "*.kql" -Recurse
    } catch {
        Write-Error $_.Exception.Message
        break
    }
    #EndRegion Fetching Parser Files

    #Region Processing Parser Files
    if ($content) {
        Write-Output "'$($content.count)' parsers found to convert"

        # Start Loop
        Foreach ($file in $content) {
            $query = $(Get-Content -Raw $file.FullName)
            
            $template = [PSCustomObject]@{
                '$schema'      = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#"
                contentVersion = "1.0.0.0"
                parameters     = @{
                    Workspace = @{
                        type = "string"
                    }
                }
                resources      = @(
                    [PSCustomObject]@{
                        name       = "[parameters('Workspace')]"
                        type       = "Microsoft.OperationalInsights/workspaces"
                        apiVersion = "2017-03-15-preview"
                        location   = "[resourcegroup().location]"
                        resources  = @([PSCustomObject]@{
                                type       = "savedSearches"
                                apiVersion = "2020-08-01"
                                name       = $($file.BaseName)
                                properties = [PSCustomObject]@{
                                    etag               = "*"
                                    displayName        = $($file.BaseName)
                                    category           = "ASIM"
                                    FunctionAlias      = $($file.BaseName)
                                    functionParameters = $($functionParameters)
                                    query              = "$query"
                                    version            = 1
                                }
                                dependsOn  = @("[resourceId('Microsoft.OperationalInsights/workspaces', parameters('Workspace'))]")
                            }
                        )
                    }
                )
            }

            $schemas = @('NetworkSession', 'WebSession', 'Authentication', 'AuditEvent', 'Dns', 'FileEvent', 'ProcessEvent')
            foreach ($schema in $schemas) {
                if ($query | Select-String $schema) {
                    $schemaType = $schema
                    switch ($schemaType) {
                        "NetworkSession" {
                            Write-Host "$schemaType" -ForegroundColor Blue
                            $functionParameters = "starttime:datetime=datetime(null), endtime:datetime=datetime(null), srcipaddr_has_any_prefix:dynamic=dynamic([]), dstipaddr_has_any_prefix:dynamic=dynamic([]), ipaddr_has_any_prefix:dynamic=dynamic([]), dstportnumber:int=int(null), hostname_has_any:dynamic=dynamic([]), dvcaction:dynamic=dynamic([]), eventresult:string='*', disabled:bool=False, pack:bool=False"
                         }
                         "WebSession" {
                            $functionParameters = "starttime:datetime=datetime(null), endtime:datetime=datetime(null), srcipaddr_has_any_prefix:dynamic=dynamic([]), ipaddr_has_any_prefix:dynamic=dynamic([]), url_has_any:dynamic=dynamic([]), httpuseragent_has_any:dynamic=dynamic([]), eventresultdetails_in:dynamic=dynamic([]), eventresult:string='*', disabled:bool=False,pack:bool=False"
                         }
                         "Authentication" {
                            $functionParameters = "starttime:datetime=datetime(null), endtime:datetime=datetime(null), targetusername_has:string='*', disabled:bool=False"
                         }
                         "AuditEvent" {
                            $functionParameters = "starttime:datetime=datetime(null), endtime:datetime=datetime(null), srcipaddr_has_any_prefix:dynamic=dynamic([]), actorusername_has_any:dynamic=dynamic([]), operation_has_any:dynamic=dynamic([]), eventtype_in:dynamic=dynamic([]), eventresult:string='*', object_has_any:dynamic=dynamic([]), newvalue_has_any:dynamic=dynamic([]), disabled:bool=False"
                         }
                         "Dns" {
                            $functionParameters = "starttime:datetime=datetime(null), endtime:datetime=datetime(null), srcipaddr:string='*', domain_has_any:dynamic=dynamic([]), responsecodename:string='*', response_has_ipv4:string='*', response_has_any_prefix:dynamic=dynamic([]), eventtype:string='Query', disabled:bool=False"
                         }
                         "FileEvent" {
                            $functionParameters = "disabled:bool=False"
                         }
                         "ProcessEvent" {
                            $functionParameters = "starttime:datetime=datetime(null), endtime:datetime=datetime(null), commandline_has_any:dynamic=dynamic([]), commandline_has_all:dynamic=dynamic([]), commandline_has_any_ip_prefix:dynamic=dynamic([]), actingprocess_has_any:dynamic=dynamic([]), targetprocess_has_any:dynamic=dynamic([]), parentprocess_has_any:dynamic=dynamic([]), targetusername_has:string='*', dvcipaddr_has_any_prefix:dynamic=dynamic([]), dvchostname_has_any:dynamic=dynamic([]), eventtype:string='*', hashes_has_any:dynamic=dynamic([]), disabled:bool=False"
                         }
                        Default {}
                    }
                }
            }

            if ($($file.BaseName) -like "vim*" ) {
                Write-Output "VIM Parameter: $functionParameters"
                $template.resources[0].resources[0].properties.functionParameters = $functionParameters
            } else {
                $template.resources[0].resources[0].properties.functionParameters = "disabled:bool=False"
            }
            #Based of output path variable export files to the right folder
            if ($null -ne $expPath) {
                $outputFile = $expPath + "/" + $($file.BaseName) + ".json"
            }
            else {

                $outputFile = $($file.DirectoryName) + "/" + $($file.BaseName) + ".json"
            }

            if ($returnObject) {
                return $template
            } else {
                $template | ConvertTo-Json -Depth 20 | Out-File $outputFile -ErrorAction Stop
            }
        }
    }
#EndRegion HelperFunctions
