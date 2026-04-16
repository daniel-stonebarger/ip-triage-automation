# Prompt for IP address
$ip = Read-Host "Enter IP address"

# Validate IPv4/IPv6 format
$parsedIp = $null
if (-not [System.Net.IPAddress]::TryParse($ip, [ref]$parsedIp)) {
    Write-Error "Invalid IP address format: $ip"
    exit 1
}

# Get API key from environment variable
$apiKey = $env:ABUSEIPDB_API_KEY

if ([string]::IsNullOrWhiteSpace($apiKey)) {
    Write-Error "API key not found. Set the ABUSEIPDB_API_KEY environment variable."
    exit 1
}

# Build API URL safely
$encodedIp = [System.Uri]::EscapeDataString($ip)
$url = "https://api.abuseipdb.com/api/v2/check?ipAddress=$encodedIp&maxAgeInDays=90"

# Headers
$headers = @{
    Key    = $apiKey
    Accept = "application/json"
}

try {
    $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get -ErrorAction Stop

    Write-Output ""
    Write-Output "--- Result ---"
    Write-Output "IP: $($response.data.ipAddress)"
    Write-Output "Abuse Score: $($response.data.abuseConfidenceScore)"
    Write-Output "Country: $($response.data.countryCode)"
    Write-Output "ISP: $($response.data.isp)"
}
catch {
    Write-Error "Failed to retrieve AbuseIPDB data: $($_.Exception.Message)"
    exit 1
}