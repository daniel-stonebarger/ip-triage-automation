# Prompt for IP address
$ipAddress = Read-Host "Enter IP address"

# Validate IPv4/IPv6 format
$parsedIp = $null
if (-not [System.Net.IPAddress]::TryParse($ipAddress, [ref]$parsedIp)) {
    Write-Error "Invalid IP address format: $ipAddress"
    exit 1
}

# Get API key from environment variable
$apiKey = $env:ABUSEIPDB_API_KEY

if ([string]::IsNullOrWhiteSpace($apiKey)) {
    Write-Error "API key not found. Set the ABUSEIPDB_API_KEY environment variable."
    exit 1
}

# Build API URL safely
$encodedIp = [System.Uri]::EscapeDataString($ipAddress)
$url = "https://api.abuseipdb.com/api/v2/check?ipAddress=$encodedIp&maxAgeInDays=90"

# Headers
$headers = @{
    Key    = $apiKey
    Accept = "application/json"
}

try {
    $response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get -ErrorAction Stop

    # Pull values from response
    $resultIp = $response.data.ipAddress
    $abuseScore = $response.data.abuseConfidenceScore
    $countryCode = $response.data.countryCode
    $isp = $response.data.isp

    # Build timestamp values
    $reportTimestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $folderTimestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

    # Determine assessment text
    if ($abuseScore -eq 0) {
        $assessment = "No known abuse reported by AbuseIPDB at time of query."
    }
    elseif ($abuseScore -le 50) {
        $assessment = "Moderate abuse score reported. Treat as a risk indicator and review in context."
    }
    else {
        $assessment = "High abuse score reported. Treat as an elevated risk indicator, not proof on its own."
    }

    # Create output folder structure
    $outputRoot = ".\output"
    $reportFolder = Join-Path $outputRoot "${folderTimestamp}_$resultIp"
    $reportPath = Join-Path $reportFolder "report.txt"

    if (-not (Test-Path $outputRoot)) {
        New-Item -Path $outputRoot -ItemType Directory | Out-Null
    }

    if (-not (Test-Path $reportFolder)) {
        New-Item -Path $reportFolder -ItemType Directory | Out-Null
    }

    # Build report content
    $reportContent = @"
IP Triage Report
---------------------------
IP Address: $resultIp
Timestamp: $reportTimestamp

Abuse Score: $abuseScore
Country: $countryCode
ISP: $isp

Assessment:
$assessment
"@

    # Save report to file
    $reportContent | Out-File -FilePath $reportPath -Encoding utf8

    # Display terminal output
    Write-Output ""
    Write-Output "--- Result ---"
    Write-Output "IP: $resultIp"
    Write-Output "Abuse Score: $abuseScore"
    Write-Output "Country: $countryCode"
    Write-Output "ISP: $isp"
    Write-Output "Assessment: $assessment"
    Write-Output "Report saved to: $reportPath"
}
catch {
    Write-Error "Failed to retrieve AbuseIPDB data: $($_.Exception.Message)"
    exit 1
}
