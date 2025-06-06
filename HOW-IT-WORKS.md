# Operation of the Hetzner DDNS System

This system dynamically maintains an updated DNS A record through Hetzner's DNS management, allowing a personal changing IP address to be linked to a permanent domain name.

## Objective:

When the public IP address of the home network changes (for example, due to DHCP or a reboot), the system detects the change and automatically updates the Hetzner DNS record to match the new address.

## Components of the System

**1. secrets-hetzner**

A file containing:
* Hetzner DNS API key
* Domain name (DOMAIN=)
* IDs of the records to be updated (RECORD_IDS=(...))
* Optionally, a list of allowed IP addresses (WHITE_IPS=(...))

**2. update-dns-hetzner.sh**

A script that:
   • Retrieves the current public IP (checkip.amazonaws.com)
   • Compares it to existing DNS A records
   • If the IP has changed (and is not on the allowed list), updates it via Hetzner's DNS API

**3. get-dns-hetzner.sh**

An auxiliary script that:
   • Retrieves the zone ID of the domain in use
   • Lists all its A records (ID, name, and current IP)
   • Suggests a RECORD_IDS=() line for the secrets-hetzner file

**4. hetzner-ddns.service**

A systemd service unit that defines a single update run:
   • Uses the WorkingDirectory setting so the script can find the secrets-hetzner file
   • Runs the update-dns-hetzner.sh script
   • Operates as Type=oneshot, meaning it executes and exits

**5. hetzner-ddns.timer**

A systemd timer unit that:
   • Regularly starts the hetzner-ddns.service unit (e.g., every 5 minutes)
   • Operates without cron
   • Can be viewed or managed with the systemctl --user command

## Impact of Use

Once the system is installed and activated:
   • When the IP address changes, the new address is automatically updated in Hetzner's DNS within a few minutes
   • From an external perspective, the DOMAIN address always points to the correct, up-to-date IP address
   • The system operates independently in the background and requires no attention

## Security

   • The API key is stored locally in the secrets-hetzner file and is not shared
   • DNS records are updated only for named records, not the entire zone
   • IP checks can be restricted to approved ones (WHITE_IPS) if certain IP transitions need to be blocked
