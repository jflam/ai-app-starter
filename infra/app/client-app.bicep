param name string
param location string = resourceGroup().location
param tags object = {}
param baseTags object = {}

param identityName string
param containerAppsEnvironmentName string
param containerRegistryName string
param applicationInsightsName string
param serverApiEndpoint string

// Used for the name of the deployed container app
var abbrs = loadJsonContent('../core/abbreviations.json')

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
  tags: baseTags
}

resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2023-05-01' existing = {
  name: containerAppsEnvironmentName
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: containerRegistryName
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

// Container App for the Client Web App
resource clientContainerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: '${abbrs.appContainerApps}${name}'
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identity.id}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppsEnvironment.id
    configuration: {
      ingress: {
        external: true
        targetPort: 80
        allowInsecure: false
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
      registries: [
        {
          identity: identity.id
          server: containerRegistry.properties.loginServer
        }
      ]
    }
    template: {
      containers: [
        {
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest' // This will be replaced during deployment
          name: name
          resources: {
            cpu: json('0.5')
            memory: '1Gi'
          }
          env: [
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              value: applicationInsights.properties.ConnectionString
            }
            {
              name: 'API_BASE_URL'
              value: serverApiEndpoint
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 10
      }
    }
  }
}

// Give the client identity ACR pull access
@description('This is the role definition ID for the built-in AcrPull role')
var acrPullRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

resource clientIdentityAcrPullRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: containerRegistry
  name: guid(containerRegistry.id, identity.id, acrPullRoleDefinitionId)
  properties: {
    roleDefinitionId: acrPullRoleDefinitionId
    principalId: identity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

output SERVICE_IDENTITY_PRINCIPAL_ID string = identity.properties.principalId
output SERVICE_NAME string = clientContainerApp.name
output SERVICE_URI string = 'https://${clientContainerApp.properties.configuration.ingress.fqdn}'
