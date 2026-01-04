using './rg.bicep'

param systemName = 'AzureEnvInspector'
param systemShort = 'aei'
param inChargeDeptName = 'default-dept'
param location = 'japaneast'
param locationShort = 'je'

param author = 'masatoshi.sato'
param version = '1.0.0'

param rgName = 'rg-${systemName}-${locationShort}'
