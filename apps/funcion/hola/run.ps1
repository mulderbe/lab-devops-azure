# run.ps1 — se ejecuta en cada petición a /api/hola.
using namespace System.Net

param($Request, $TriggerMetadata)

try {
    # 1. Pedir un token para Key Vault a la identidad administrada de la Function.
    #    Azure inyecta IDENTITY_ENDPOINT e IDENTITY_HEADER: no hay ninguna contraseña en el código.
    $token = Invoke-RestMethod -Method Get `
        -Uri "$($env:IDENTITY_ENDPOINT)?resource=https://vault.azure.net&api-version=2019-08-01" `
        -Headers @{ 'X-IDENTITY-HEADER' = $env:IDENTITY_HEADER }

    # 2. Leer el secreto con ese token.
    $secreto = Invoke-RestMethod -Method Get `
        -Uri "https://$($env:KV_NAME).vault.azure.net/secrets/mensaje-lab?api-version=7.4" `
        -Headers @{ Authorization = "Bearer $($token.access_token)" }

    $mensaje = $secreto.value
    $estado  = [HttpStatusCode]::OK
}
catch {
    # Si el rol aún no se propaga, Key Vault responde 403: lo mostramos en vez de ocultarlo.
    Write-Warning "No se pudo leer el Key Vault: $($_.Exception.Message)"
    $mensaje = "ERROR al leer el Key Vault: $($_.Exception.Message)"
    $estado  = [HttpStatusCode]::InternalServerError
}

$cuerpo = "Lab 5 de 6 - Azure Function (PowerShell)`nMensaje del Key Vault: $mensaje`n"

Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = $estado
    Headers    = @{ 'Content-Type' = 'text/plain; charset=utf-8' }
    Body       = $cuerpo
})
