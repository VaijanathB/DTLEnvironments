$certFolder = "C:\certificates"
$certFilePath = "$certFolder\certFile5.pfx"
$certStartDate = (Get-Date).Date
$certStartDateStr = $certStartDate.ToString("MM/dd/yyyy")
$certEndDate = $certStartDate.AddYears(1)
$certEndDateStr = $certEndDate.ToString("MM/dd/yyyy")
$certName = "hdiadlsdemovj"
$certPassword = "Microsoft@1"
$certPasswordSecureString = ConvertTo-SecureString $certPassword -AsPlainText -Force

mkdir $certFolder

$cert = New-SelfSignedCertificate -DnsName $certName -CertStoreLocation cert:\CurrentUser\My -KeySpec KeyExchange -NotAfter $certEndDate -NotBefore $certStartDate
$certThumbprint = $cert.Thumbprint
$cert = (Get-ChildItem -Path cert:\CurrentUser\My\$certThumbprint)

Export-PfxCertificate -Cert $cert -FilePath $certFilePath -Password $certPasswordSecureString


$clusterName = "testcl1vj11"
$certificatePFX = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($certFilePath, $certPasswordSecureString)
$credential = [System.Convert]::ToBase64String($certificatePFX.GetRawCertData())

$application = New-AzureRmADApplication -DisplayName $certName -HomePage "https://$clusterName.azurehdinsight.net" -IdentifierUris "https://$clusterName.azurehdinsight.net"  -CertValue $credential -StartDate $certStartDate -EndDate $certEndDate
                        
$servicePrincipal = New-AzureRmADServicePrincipal -ApplicationId $application.ApplicationId

"Service Principal Application ID"
$servicePrincipal.ApplicationId

"Service Principal Object ID"
$servicePrincipal.Id

"Tenant Id"
(Get-AzureRmContext).Tenant.TenantId


[System.Convert]::ToBase64String((Get-Content $certFilePath -Encoding Byte)) > .\spcontents.txt
