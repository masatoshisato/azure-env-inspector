// Create the resource group.
//
// rgName : The name of the resource group to create. 
//    'rg-aei-je'
//    Format is used, where 'aei' is the system short name and 'je' is the location short name. 
//
// rgLocation : The Azure region where the resource group will be created.
//    'japaneast'
//    This is the default location for the resource group.

metadata name = 'Resource Group for Azure Env Inspector'
targetScope = 'subscription'


////////////////////////////////////////////////////////////////////////////////
// Parameters for resource group configuration.

param systemName string
param systemShort string
param inChargeDeptName string
param location string
param locationShort string
param author string
param version string
param rgName string

param deploymentDate string = utcNow('yyyy-MM-dd')
param deploymentName string = deployment().name

param tags object = {
  SystemName: systemName
  DeptName: inChargeDeptName
  DeploymentDate: deploymentDate
  DeploymentBy: author
  DeploymentVersion: version
  DeploymentName: deploymentName
}

////////////////////////////////////////////////////////////////////////////////
// Create the resource group with specified tags.

resource rgAei 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: rgName
  location: location
  tags: tags
}
