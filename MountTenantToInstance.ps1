$ServerInstance = "BC210"
$TenantName = "tenant2"
$TenantDataBaseName = "Tenant2"

Mount-NAVTenant -DatabaseName $TenantDataBaseName -ServerInstance $ServerInstance -Tenant $TenantName -AllowAppDatabaseWrite -Force -NasServicesEnabled -OverwriteTenantIdInDatabase
Sync-NAVTenant -ServerInstance $ServerInstance -Force -Tenant $TenantName