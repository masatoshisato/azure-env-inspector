targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment which is used to generate a short unique hash for resource names.')
param environmentName string

@minLength(1)
@description('Primary location for all resources.')
param location string

@description('PostgreSQL administrator login name.')
param postgresAdminLogin string = 'pgadmin'

@secure()
@description('PostgreSQL administrator password.')
param postgresAdminPassword string

@description('PostgreSQL database name.')
param postgresDatabaseName string = 'appdb'

@description('Enable Entra ID authentication.')
@allowed([
  'Enabled'
  'Disabled'
])
param entraIdAuthEnabled string = 'Enabled'

@description('Entra ID administrator object ID.')
param entraIdAdminObjectId string = ''

@description('Entra ID administrator principal name.')
param entraIdAdminPrincipalName string = ''

// Tags that should be applied to all resources.
var tags = {
  'azd-env-name': environmentName
}

// Generate a unique token to be used in naming resources.
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

// Name of the resource group where all resources will be created.
var resourceGroupName = 'rg-${environmentName}'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module postgres 'postgresql.bicep' = {
  scope: rg
  params: {
    location: location
    tags: tags
    serverName: 'psql-${resourceToken}'
    administratorLogin: postgresAdminLogin
    administratorLoginPassword: postgresAdminPassword
    databaseName: postgresDatabaseName
    entraIdAuthEnabled: entraIdAuthEnabled
    entraIdAdminObjectId: entraIdAdminObjectId
    entraIdAdminPrincipalName: entraIdAdminPrincipalName
    entraIdTenantId: subscription().tenantId
  }
}

// Outputs
output AZURE_LOCATION string = location
output AZURE_RESOURCE_GROUP string = rg.name
output POSTGRES_SERVER_NAME string = postgres.outputs.serverName
output POSTGRES_DATABASE_NAME string = postgres.outputs.databaseName
output POSTGRES_SERVER_FQDN string = postgres.outputs.serverFqdn
output ENTRA_ID_AUTH_ENABLED bool = postgres.outputs.entraIdAuthEnabled
output ENTRA_ID_ADMIN_NAME string = postgres.outputs.entraIdAdminName
