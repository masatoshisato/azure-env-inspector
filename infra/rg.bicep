// Additional metadata for the Bicep file.
metadata name = 'Resource Group for Azure Env Inspector'
metadata version = '1.0.0'
metadata author = 'masatoshi.sato at gmail.com'

// Define the target scope for the Bicep deployment.
targetScope = 'subscription'

////////////////////////////////////////////////////////////////////////////////
// Parameters for resource group configuration.
param systemName string = 'azure-env-inspector'
param systemShort string = 'aei'
param deptName string = 'default-dept'
param location string = 'japaneast'
param locationShort string = 'je'
param deploymentDate string = utcNow('d')
param deploymentBy string = 'masatoshi.sato'
param rgName string = 'rg-${systemShort}-${locationShort}'

////////////////////////////////////////////////////////////////////////////////
// Create the resource group with specified tags.
resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: rgName
  location: location
  tags: {
    SystemName: systemName
    SystemShort: systemShort
    DeptName: deptName
    Location: location
    LocationShort: locationShort
    DeploymentDate: deploymentDate
    DeploymentBy: deploymentBy
  }
}
