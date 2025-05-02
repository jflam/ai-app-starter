param name string
param location string = resourceGroup().location
param tags object = {}
param baseTags object = {}

param identityName string
param containerAppsEnvironmentName string
param containerRegistryName string
param applicationInsightsName string

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

// Container App for the API
resource apiContainerApp 'Microsoft.App/containerApps@2023-05-01' = {
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
        targetPort: 4000
        allowInsecure: false
        corsPolicy: {
          allowedOrigins: [
            'https://${abbrs.appContainerApps}client.${containerAppsEnvironment.properties.defaultDomain}'
            'http://localhost:3000'
          ]
          allowedMethods: ['*']
          allowedHeaders: ['*']
          exposeHeaders: ['*']
          maxAge: 600
        }
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
              name: 'PORT'
              value: '4000'
            }
            {
              name: 'NODE_ENV'
              value: 'production'
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

// Give the API identity ACR pull access
@description('This is the role definition ID for the built-in AcrPull role')
var acrPullRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

resource apiIdentityAcrPullRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: containerRegistry
  name: guid(containerRegistry.id, identity.id, acrPullRoleDefinitionId)
  properties: {
    roleDefinitionId: acrPullRoleDefinitionId
    principalId: identity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

output SERVICE_IDENTITY_PRINCIPAL_ID string = identity.properties.principalId
output SERVICE_NAME string = apiContainerApp.name
output SERVICE_URI string = 'https://${apiContainerApp.properties.configuration.ingress.fqdn}'
output SERVICE_API_URI string = 'https://${apiContainerApp.properties.configuration.ingress.fqdn}'
