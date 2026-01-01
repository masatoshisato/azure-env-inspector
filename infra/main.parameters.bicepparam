using './main.bicep'

param environmentName = readEnvironmentVariable('AZURE_ENV_NAME', 'dev')
param location = readEnvironmentVariable('AZURE_LOCATION', 'japaneast')
param postgresAdminLogin = readEnvironmentVariable('POSTGRES_ADMIN_LOGIN', 'pgadmin')
param postgresAdminPassword = readEnvironmentVariable('POSTGRES_ADMIN_PASSWORD')
param postgresDatabaseName = readEnvironmentVariable('POSTGRES_DATABASE_NAME', 'appdb')
param entraIdAuthEnabled = readEnvironmentVariable('ENTRA_ID_AUTH_ENABLED', 'Enabled')
param entraIdAdminObjectId = readEnvironmentVariable('ENTRA_ID_ADMIN_OBJECT_ID', '')
param entraIdAdminPrincipalName = readEnvironmentVariable('ENTRA_ID_ADMIN_PRINCIPAL_NAME', '')
