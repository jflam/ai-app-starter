# Deployment Instructions

This application is set up to be deployed to Azure Container Apps using the Azure Developer CLI (azd). Follow these steps to deploy:

## Prerequisites

1. Install the Azure Developer CLI (azd)
   ```
   winget install microsoft.azd
   ```

2. Install Azure CLI (az)
   ```
   winget install -e --id Microsoft.AzureCLI
   ```

## Deployment Steps

1. Log in to Azure
   ```
   azd auth login
   ```

2. Initialize the environment (one-time setup)
   ```
   azd init
   ```

3. Provision Azure resources and deploy the application
   ```
   azd up
   ```
   This will:
   - Create needed Azure resources
   - Build container images
   - Push images to Azure Container Registry
   - Deploy to Azure Container Apps
   - Set up managed identities for secure authentication

## Verify Deployment

After deployment completes, navigate to the provided client URL to see your application running in Azure.

## Troubleshooting

If you encounter any errors during deployment:

1. Check Azure Container App logs:
   ```
   az containerapp logs show --name <app-name> --resource-group <resource-group> --follow
   ```

2. Verify your container images are built and pushed correctly:
   ```
   az acr repository list -n <registry-name> -o table
   ```

3. Check the container app configuration:
   ```
   az containerapp show -n <app-name> -g <resource-group> -o json
   ```

## Clean Up

To remove all deployed resources:
   ```
   azd down
   ```
