# Basic Configuration

## General Server Configuration
#### Base Directory
The base directory for the MLSMTP installation must be specified
in `default.json`.
```json
{
  "base_dir": "/opt/mlsmtp"
}
``` 
#### Mail Name
The SMTP mail name is set in `default.json`.
```json
{
  "mailname": "localhost"
}
```
#### ESMTP
ESMTP is enabled or disabled in `default.json`.
```json
{
  "esmtp_enable": true
}
```
#### Require HELO
The HELO greeting can be required or not in `default.json`.
```json
{
  "require_helo": true
}
```
#### Postmaster Email
The Postmaster email, optionally present in some delivery error
responses, can be set in `default.json`.
```json
{
  "contact_email": "postmaster@localhost"
}
```
#### 8-Bit Support
8-bit support for inbound mail can be enabled or disabled
in `default.json`.
```json
{
  "support_8_bit": true
}
```
#### Max Size
The maximum data size permitted can be set in bytes in
`default.json`.
```json
{
  "max_size": 10000000000
}
```
#### Disabled Commands
Commands can be disabled in `default.json`. Disabling
the `VRFY` and `EXPN` commands is recommended to increase
security and prevent enumeration attacks.
```json
{
  "disable_commands": [
    "VRFY",
    "EXPN"
  ],
}
```
#### Exception Handling
Whether to raise exceptions and abort threads is specified
in `defaults.json`.
```json
{
  "threads": {
    "abort_on_exception": false,
    "report_on_exception": false
  }
}
```
