[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Declare variables
$api = @{
    "endpoint" = 'https://api.meraki.com/api/v0'
    "key" = (Get-Content config.json | ConvertFrom-Json).MerakiApiKey
    }
$Header = @{
        "X-Cisco-Meraki-API-Key" = $api.key
        "Content-Type" = 'application/json'
    }
$Category = "Adult and Pornography"

# Get organization ID
$api.url = "/organizations"
$uri = $api.endpoint + $api.url
$Response = Invoke-WebRequest -Uri $uri -Method GET -Headers $Header | ConvertFrom-Json
$orgID = $Response.id

# Get networks
$api.url = "/organizations/$orgID/networks"
$uri = $api.endpoint + $api.url
$Response = Invoke-WebRequest -Uri $uri -Method GET -Headers $Header | ConvertFrom-Json
$Networks = $Response | Where-Object {$_.Name -eq "Witt Home"}

foreach ($Network in $Networks) {
    # Get event logs
    $api.url = "/networks/$($Network.id)/events"
    $parameters = "?productType=appliance"
    $uri = $api.endpoint + $api.url + $parameters
    $Body = @{'includedEventTypes' = @('cf_block')} | ConvertTo-Json
    $Response = Invoke-WebRequest -Uri $uri -Method GET -Headers $Header -Body $Body  | ConvertFrom-Json
    $Events = $Response.events

    foreach ($Event in $Events) {
        if ($Event.eventdata.category -match $Category) {
            # Send notification
            # Options: twilio, AWS SNS, Azure
        }
    }

}