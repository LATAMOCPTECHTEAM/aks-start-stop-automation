$connectionName = "AzureRunAsConnection"

$clusters = @(
       [pscustomobject]@{AKS_NAME='<<aksservicename>>';AKS_RG='<<aksserviceresourcegroup>>';AKS_SUBSCRIPTION='<<aksservicesubscription>>'}
)

function RunScript()
{
    $clusters | ForEach-Object {
        $AKS_SUBSCRIPTION=$_.AKS_SUBSCRIPTION
        $AKS_RG=$_.AKS_RG
        $AKS_NAME=$_.AKS_NAME
        
        $URI="https://management.azure.com/subscriptions/$AKS_SUBSCRIPTION/resourceGroups/$AKS_RG/providers/Microsoft.ContainerService/managedClusters/$AKS_NAME/stop?api-version=2020-09-01"
        $token=Get-AzureRmBearerToken
        $headers = @{
            'Authorization' = "Bearer $token"
        }
        Invoke-RestMethod -Method Post -Uri $URI -ContentType "application/json" -Headers $headers
    }
}

function Authenticate(){
    try
    {
        # Get the connection "AzureRunAsConnection "
        $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

        "Logging in to Azure..."
        Add-AzureRmAccount `
            -ServicePrincipal `
            -TenantId $servicePrincipalConnection.TenantId `
            -ApplicationId $servicePrincipalConnection.ApplicationId `
            -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
    }
    catch {
        if (!$servicePrincipalConnection)
        {
            $ErrorMessage = "Connection $connectionName not found."
            throw $ErrorMessage
        } else{
            Write-Error -Message $_.Exception
            throw $_.Exception
        }
    }
}


function Get-AzureRmCachedAccessToken()
{
    $ErrorActionPreference = 'Stop'
  
    if(-not (Get-Module AzureRm.Profile)) {
        Import-Module AzureRm.Profile
    }
    $azureRmProfileModuleVersion = (Get-Module AzureRm.Profile).Version
    # refactoring performed in AzureRm.Profile v3.0 or later
    if($azureRmProfileModuleVersion.Major -ge 3) {
        $azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
        if(-not $azureRmProfile.Accounts.Count) {
            Write-Error "Ensure you have logged in before calling this function."    
        }
    } else {
        # AzureRm.Profile < v3.0
        $azureRmProfile = [Microsoft.WindowsAzure.Commands.Common.AzureRmProfileProvider]::Instance.Profile
        if(-not $azureRmProfile.Context.Account.Count) {
            Write-Error "Ensure you have logged in before calling this function."    
        }
    }
  
    $currentAzureContext = Get-AzureRmContext
    $profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azureRmProfile)
    Write-Debug ("Getting access token for tenant" + $currentAzureContext.Tenant.TenantId)
    $token = $profileClient.AcquireAccessToken($currentAzureContext.Tenant.TenantId)
    $token.AccessToken
}

function Get-AzureRmBearerToken()
{
    $ErrorActionPreference = 'Stop'
    ('{0}' -f (Get-AzureRmCachedAccessToken))
}

Authenticate
RunScript