# PowerShell Commands

---

### Active Directory

- **Import-Module:** Loads the AD module
- **Get-ADUser:** Pulls all AD user accounts with full property set for bulk ops
- **Where-Object:** filters query results down to the target subset
- **Sort-Object:** Sorts output by any property, ascending or descending
- **Select-Object:** Strips an object down to only the fields you need
- **Get-ADGroup:** Pulls an AD group and its current membership
- **Add-ADGroupMember:** Injects a user or object into an AD group
- **Set-ADUser:** Stamps attribute changes directly onto an AD user
- **Disable-ADAccount:** Blocks login without removing the account from AD
- **Move-ADObject:** Relocates an AD object to a target OU

---

### SCCM

- **Import-Module:** Loads the SCCM module before any CM cmdlets will run
- **Get-CMAutoDeploymentRule:** Audits ADR schedules to pinpoint when auto deployments are set to fire
- **Get-CMBoundaryGroup:** pulls all boundary groups to surface orphaned or broken entries
- **Get-CMClientSetting:** Reads client policy config
- **Set-CMClientSettingBackgroundIntelligentTransfer:** Caps BITS bandwidth on a client policy during business hours
- **Get-CMDistributionPoint:** Audits DPs and their current rate limit config
- **Set-CMDistributionPoint:** Pushes updated settings to a distribution point
- **Get-CMPackage:** Pulls package metadata to confirm build version and config
- **New-CMDeviceCollection:** Builds a device collection to scope a targeted deployment
- **Get-CMDeployment:** Checks deployment status across target machines
- **Invoke-CMClientNotification:** Forces an immediate policy refresh when clients aren't syncing

---

### Exchange

- **Connect-ExchangeOnline:** Opens an Exchange PowerShell session
- **Get-MessageTrace:** Traces mail delivery to diagnose routing or filtering drops
- **Get-TransportRule:** audits active transport rules to identify what's intercepting mail flow
- **Get-MalwareFilterPolicy:** Reads malware filter config to rule out a policy block
- **Get-SafeAttachmentPolicy:** Checks Defender Safe Attachments config for anything blocking mail
- **New-Mailbox:** Provisions a new mailbox in Exchange
- **Get-Recipient:** Audits existing recipients for naming and alias conflicts before provisioning
- **Add-MailboxPermission:** Grants full access or send as rights on a mailbox
- **Set-MailboxJunkEmailConfiguration:** Injects a trusted sender to bypass junk filtering
- **Resolve-DnsName:** Queries SPF, DKIM, and DMARC records directly during mail flow investigations

---

### PnP PowerShell

- **Connect-PnPOnline:** Authenticates to a SharePoint site via app registration and cert
- **Add-PnPFile:** uploads a local file directly to a SharePoint library
- **New-PnPFolder:** Creates a destination folder in a SharePoint library
- **Grant-PnPAzureADAppSitePermission:** Grants the app registration write access to the SharePoint site

---

### Bitlocker

- **Get-Tpm:** Validates TPM state before attempting encryption
- **Get-BitLockerVolume:** reads Bitlocker status on a target drive
- **Enable-BitLocker:** Provisions Bitlocker on a volume with a specified encryption method and key protectors

---

### REST API / Web

- **Invoke-RestMethod:** Fires authenticated HTTP requests at a REST API and returns parsed results
- **ConvertTo-Json:** Serializes a PS object into a JSON request body
- **ConvertFrom-Json:** Deserializes a JSON response into a usable PS object
- **New-Object:** Instantiates a .NET class directly for crypto operations like HMAC signing

---

### Core Utility

- **ForEach-Object:** Iterates a collection and runs a script block against each item
- **Export-Excel:** Dumps data into a formatted multi-sheet excel file
- **Import-Excel:** Pulls an excel file into PS objects for processing
- **Get-Content:** reads a file into PS line by line
- **New-SelfSignedCertificate:** Generates a self-signed cert for auth or encryption
- **Restart-Service:** Bounces a service to clear a hung or failed state
- **Get-Service:** Checks live service state
- **Get-ChildItem:** Scans a directory for files and folders
- **Out-File:** Writes output to disk
- **Export-Csv:** dumps data to a CSV
- **Format-Table:** Formats pipeline output as a readable table in the console
- **Write-Host:** Prints status output directly to the console
- **Write-Output:** Sends objects down the pipeline
- **Write-Error:** writes to the error stream for non-terminating failures
- **Read-Host:** Pauses execution and prompts for input
