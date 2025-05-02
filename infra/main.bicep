targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource conventions')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('Id of the user or app to assign application roles')
param principalId string = ''

// Tags that should be applied to all resources.
var baseTags = {
  'azd-env-name': environmentName
}

// Generate a unique token to be used in naming resources.
var resourceToken = uniqueString(subscription().id, environmentName)

// Name of the service defined in azure.yaml
var serverServiceName = 'server'
var clientServiceName = 'client'

// Organize resources in a resource group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${environmentName}-rg'
  location: location
  tags: baseTags
}

// Monitor application with Azure Monitor
module monitoring './core/monitor/monitoring.bicep' = {
  name: 'monitoring'
  scope: resourceGroup
  params: {
    location: location
    tags: baseTags
    logAnalyticsName: '${environmentName}-logworkspace'
    applicationInsightsName: '${environmentName}-appinsights'
    applicationInsightsDashboardName: '${environmentName}-appinsights-dashboard'
  }
}

// Container apps host (including container registry)
module containerApps './core/host/container-apps.bicep' = {
  name: 'container-apps'
  scope: resourceGroup
  params: {
    name: 'app'
    location: location
    tags: baseTags
    containerAppsEnvironmentName: '${environmentName}-containerapps-env'
    containerRegistryName: '${resourceToken}registry'
    logAnalyticsWorkspaceName: monitoring.outputs.logAnalyticsWorkspaceName
  }
}

// The server API
module serverApi './app/server-api.bicep' = {
  name: 'server-api'
  scope: resourceGroup
  params: {
    name: serverServiceName
    location: location
    tags: union(baseTags, { 'azd-service-name': serverServiceName })
    baseTags: baseTags
    identityName: '${environmentName}-${serverServiceName}-id'
    containerAppsEnvironmentName: containerApps.outputs.environmentName
    containerRegistryName: containerApps.outputs.registryName
    applicationInsightsName: monitoring.outputs.applicationInsightsName
  }
}

// The client app
module clientApp './app/client-app.bicep' = {
  name: 'client-app'
  scope: resourceGroup
  params: {
    name: clientServiceName
    location: location
    tags: union(baseTags, { 'azd-service-name': clientServiceName })
    baseTags: baseTags
    identityName: '${environmentName}-${clientServiceName}-id'
    containerAppsEnvironmentName: containerApps.outputs.environmentName
    containerRegistryName: containerApps.outputs.registryName
    applicationInsightsName: monitoring.outputs.applicationInsightsName
    serverApiEndpoint: serverApi.outputs.SERVICE_API_URI
  }
}

// App outputs
output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output APPLICATIONINSIGHTS_CONNECTION_STRING string = monitoring.outputs.applicationInsightsConnectionString
output RESOURCE_GROUP_ID string = resourceGroup.id
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerApps.outputs.registryLoginServer

// Server outputs
output SERVER_NAME string = serverApi.outputs.SERVICE_NAME
output SERVER_URI string = serverApi.outputs.SERVICE_URI
output API_BASE_URL string = serverApi.outputs.SERVICE_API_URI

// Client outputs
output CLIENT_NAME string = clientApp.outputs.SERVICE_NAME
output CLIENT_URI string = clientApp.outputs.SERVICE_URI
