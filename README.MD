## logs.ps1

Get logs with ID 2889

.\logs.ps1 (nameFile) (begin) (end)

nameFile: outputfile name without .csv extension

.\logs.ps1 (nameFile): logs are obtained from the previous day at 6 AM

.\logs.ps1 (nameFile) all: get all logs

eg:

.\logs.ps1 ad01

.\logs.ps1 ad01 all

### note1

- must be executed on the DC that previously enabled the capture of events 2889

- The file must always be named, for now it only works in the two ways seen above

- don't use output as the output name, the script creates a temporary file with that name and there may be problems

## log-excel.ps1

convert the cvs that was obtained with the previous script to an excel file

.\log-excel.ps1 (inputFile) (outputFile)

inputFile: it is a csv file, the extension should not be placed only the name

outputFile: it is an excel file, the file extension should not be placed

### note2

- must be run on a computer that has excel

- if the Remove-Item -Path $ result_csv line is uncommented in the code, the csv that was given as input will be deleted

## extract-ip-usr.ps1

get client IP from firs csv

.\extract-ip-usr.ps1 -path "\path\to\file" -inputFile "inputfile-without-extension" "outputfile-without-extension"

# Info

At first I tell you what should be done to check if there are computers that want to connect using the insecure protocol. To begin we should review these events in Applications and Services\Directory Service:

- 2886: it will indicate that our DC does not require LDAP signatures

- 2887: it will tell us how many links were produced
 
Then, if we change the value of a register in the DC we should be able to see which equipment uses this insecure protocol. These are the events:

- 2888: it will tell us if the server is configured to reject unsigned SASL LDAP links or simple LDAP links through a connection other than SSL / TLS, the directory server will record a 2888 summary event once every 24 hours when they occur such linking attempts.

- 2889: it will show us who is using this non-secure protocol, indicating from which IP it is being used.

The DC registry can be modified with the following command via Powershell:
> Reg Add HKLM \ SYSTEM \ CurrentControlSet \ Services \ NTDS \ Diagnostics / v "16 LDAP Interface Events" / t REG_DWORD / d 2

This will change the value of the registry that is in the path that can be seen in the command.

We should leave it for at least a week and review the events that are generated, in order to identify the computers that are using the insecure protocol.

Important: once we identify the computers, we should verify if the clients have the CVE-2017-8563 security update installed before enabling channel binding, otherwise compatibility problems and LDAP over SSL authentication requests may arise. / TLS that worked previously may stop working, although by default this setting is disabled.

Then another record must be modified:
> AD - HKEY_LOCAL_MACHINE \ System \ CurrentControlSet \ Services \ NTDS \ Parameters

with LdapEnforceChannelBinding with the value 1, which indicates that it is enabled, when supported.

Subsequently, the signature requirement must be modified in a GPO, both on the server and on the client.

## In summary:

We have to review the events with these IDs: 2886,2887,2888,2889

- In Clients, we must have CVE-2017-8563 as a prerequisite "Extended protection for authentication" before enabling LDAP 

- CBT and LDAP Signing

If we don't want to wait for the January 2020 update:

- Enable LdapEnforceChannelBinding = 1

- Enable GPO LDAP server signing:

- DCs = policy "Domain controller: LDAP server signing requirements" = Require Signing

- Servers / Clients = policy "Network security: LDAP client signing requirements = Require Signing

### Some links where you can read a little more information about it:

- Information about the process: https://techcommunity.microsoft.com/t5/core-infrastructure-and-security/ldap-channel-binding-and-ldap-signing-requirements-update-now/ba-p/921536

- CVE-2017-8563 | Windows Elevation of Privilege Vulnerability: https://portal.msrc.microsoft.com/en-us/security-guidance/advisory/CVE-2017-8563

- GPO changes: https://support.microsoft.com/en-us/help/935834/how-to-enable-ldap-signing-in-windows-server-2008

- Using the LdapEnforceChannelBinding: https://support.microsoft.com/en-us/help/4034879/how-to-add-the-ldapenforcechannelbinding-registry-entry