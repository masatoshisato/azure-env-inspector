@description('Location for all resources.')
param location string

@description('Tags to apply to resources.')
param tags object = {}

@minLength(3)
@maxLength(63)
@description('Name of the PostgreSQL flexible server.')
param serverName string

@description('PostgreSQL administrator login name.')
param administratorLogin string

@secure()
@description('PostgreSQL administrator password.')
param administratorLoginPassword string

@description('PostgreSQL database name.')
param databaseName string

@description('PostgreSQL version.')
@allowed([
  '18'
  '17'
  '16'
  '15'
  '14'
  '13'
])
param postgresVersion string = '16'

@description('Compute tier of the server.')
@allowed([
  'Burstable'
  'GeneralPurpose'
  'MemoryOptimized'
])
param skuTier string = 'Burstable'

@description('Compute size name.')
param skuName string = 'Standard_B1ms'

@description('Storage size in GB.')
@minValue(32)
@maxValue(16384)
param storageSizeGB int = 32

@description('Backup retention days.')
@minValue(7)
@maxValue(35)
param backupRetentionDays int = 7

@description('Enable geo-redundant backup.')
@allowed([
  'Enabled'
  'Disabled'
])
param geoRedundantBackup string = 'Disabled'

@description('Enable high availability.')
@allowed([
  'Enabled'
  'Disabled'
])
param highAvailability string = 'Disabled'

@description('Availability zone for the server.')
param availabilityZone string = ''

@description('Enable Entra ID authentication.')
@allowed([
  'Enabled'
  'Disabled'
])
param entraIdAuthEnabled string = 'Enabled'

@description('Entra ID administrator object ID (required when entraIdAuthEnabled is Enabled).')
param entraIdAdminObjectId string = ''

@description('Entra ID administrator principal name (required when entraIdAuthEnabled is Enabled).')
param entraIdAdminPrincipalName string = ''

@description('Entra ID tenant ID.')
param entraIdTenantId string = subscription().tenantId

// PostgreSQL Flexible Server
resource postgresServer 'Microsoft.DBforPostgreSQL/flexibleServers@2025-08-01' = {
  name: serverName
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    version: postgresVersion
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    availabilityZone: !empty(availabilityZone) ? availabilityZone : null
    storage: {
      storageSizeGB: storageSizeGB
      autoGrow: 'Enabled'
    }
    backup: {
      backupRetentionDays: backupRetentionDays
      geoRedundantBackup: geoRedundantBackup
    }
    highAvailability: highAvailability == 'Enabled' ? {
      mode: 'ZoneRedundant'
    } : null
    authConfig: {
      activeDirectoryAuth: entraIdAuthEnabled
      passwordAuth: 'Enabled'
      tenantId: entraIdAuthEnabled == 'Enabled' ? entraIdTenantId : null
    }
  }
}

// PostgreSQL Database
resource postgresDatabase 'Microsoft.DBforPostgreSQL/flexibleServers/databases@2025-08-01' = {
  parent: postgresServer
  name: databaseName
  properties: {
    charset: 'UTF8'
    collation: 'en_US.utf8'
  }
}

// Firewall rule to allow Azure services
resource firewallRuleAzure 'Microsoft.DBforPostgreSQL/flexibleServers/firewallRules@2025-08-01' = {
  parent: postgresServer
  name: 'AllowAllAzureServicesAndResourcesWithinAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// Entra ID Administrator (optional)
resource entraIdAdministrator 'Microsoft.DBforPostgreSQL/flexibleServers/administrators@2025-08-01' = if (entraIdAuthEnabled == 'Enabled' && !empty(entraIdAdminObjectId)) {
  parent: postgresServer
  name: entraIdAdminPrincipalName
  properties: {
    principalType: 'User'
    principalName: entraIdAdminPrincipalName
    tenantId: entraIdTenantId
    objectId: entraIdAdminObjectId
  }
}

// Outputs
output serverName string = postgresServer.name
output serverFqdn string = postgresServer.properties.fullyQualifiedDomainName
output databaseName string = postgresDatabase.name
output serverId string = postgresServer.id
output entraIdAuthEnabled bool = entraIdAuthEnabled == 'Enabled'
output entraIdAdminName string = entraIdAuthEnabled == 'Enabled' && !empty(entraIdAdminPrincipalName) ? entraIdAdminPrincipalName : ''
