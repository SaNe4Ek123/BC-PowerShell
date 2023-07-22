$DataBaseServer = "localhost"
$AppDatabaseName = "Tenant2"
$NewCompanyName = "My Company"

$PathLicenseFile = "C:\VengoVision\BC\hwm-bc22ru-7732379.bclicense"
$PathSystemApp = "C:\VengoVision\BC\BC-V22\BC-V22\Dynamics.365.BC.46853.RU.DVD\Applications\system application\source\Microsoft_System Application.app"
$PathBasicApp = "C:\VengoVision\BC\BC-V22\BC-V22\Dynamics.365.BC.46853.RU.DVD\Applications\BaseApp\Source\Microsoft_Base Application.app"

$TempServerInstance = "SingleIns"
$TempServerInstancePort = 12345

# Создаём instance на котором будем создавать базу
New-NAVServerInstance -ServerInstance $TempServerInstance -ManagementServicesPort $TempServerInstancePort -ClientServicesCredentialType Windows -Force
Set-NAVServerInstance -ServerInstance $TempServerInstance -Start

# Создаём базу
New-NAVApplicationDatabase -DatabaseName $AppDatabaseName -DatabaseServer $DataBaseServer -Force

# Перенастраиваем instance
Set-NAVServerConfiguration -ServerInstance $TempServerInstance -Keyname Multitenant -KeyValue "false"
Set-NAVServerConfiguration -ServerInstance $TempServerInstance -Keyname DatabaseName -KeyValue $AppDatabaseName
Restart-NAVServerInstance -ServerInstance $TempServerInstance -Force

# Импортируем лицензию
Import-NAVServerLicense -ServerInstance $TempServerInstance -LicenseFile $PathLicenseFile -Force
Restart-NAVServerInstance -ServerInstance $TempServerInstance -Force

# Синхронизируем базу с instance
Sync-NAVTenant -ServerInstance $TempServerInstance -Force

# Публикуем, синхронизируем и устанавливаем базовые приложения
Publish-NAVApp -ServerInstance $TempServerInstance -Path $PathSystemApp -Force -SkipVerification
Publish-NAVApp -ServerInstance $TempServerInstance -Path $PathBasicApp -Force -SkipVerification

$AppList = Get-NAVAppInfo -ServerInstance $TempServerInstance
foreach ($App in $AppList)
{
    Sync-NAVApp -ServerInstance $TempServerInstance -AppId $App.AppId -Force  
    Install-NAVApp -ServerInstance $TempServerInstance -AppId $App.AppId -Force
}

# Создаём компанию
New-NAVCompany -ServerInstance $TempServerInstance -CompanyName $NewCompanyName -Force

# Удаляем ранее созданный instance
Set-NAVServerInstance -ServerInstance $TempServerInstance -Stop
Remove-NAVServerInstance -ServerInstance $TempServerInstance -Force





