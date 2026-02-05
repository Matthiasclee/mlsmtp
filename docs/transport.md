# Transport Configuration

## Miscellaneous Transport Settings
#### Timeout
The maximum time (in seconds) that can be spent on a delivery attempt
is specified in `default.json`.
```json
{
  "transport": {
    "delivery_timeout": 5
  }
}
```
#### Delivery Retries
The maximum amount of delivery retries for a given message is specified
in `default.json`.
```json
{
  "transport": {
    "max_retries": 10
  }
}
```
#### Retry Interval
The time (in seconds) between retries is specified in `default.json`.
```json
  "transport": {
    "retry_interval": 600
  }
```

## Transport Rules
Transport rules, defining where an email is to
be delivered, are specified in `transport_rules.json`.
The format is as follows:
```json
{
  "<recipient address regex>": [ "<destination>", [ "<proxy>" ] ]
}
```
An email will be delivered to the destination of the first recipient
address regex it matches.

#### Local Deliveries
To deliver an email locally, the destination should consist of
one element, specifying the name of the local account where the
email is to be stored. `%u`, `%d`, and `%a` will be substituted
for the email user, email domain, and full email address of the
recipient.
```json
{
  "^postmaster@mlsmtp\\.example$": [ "root" ],
  "^.*@mlsmtp\\.example$": [ "%u" ],
  "^.*@.*mlsmtp\\.example$": [ "%u_%d" ]
}
```
*In the above example, mail delivered to user@mlsmtp.example will
be received by `user`, mail delivered to user@a.mlsmtp.example will
be delivered to user_a, however mail delivered to
postmaster@mlsmtp.example will be delivered to root.*

#### Proxied Remote Deliveries
To route email going to certain destinations through a proxy, the
destination should consist of the address to deliver the mail to, and
the proxy server.
```json
{
  "^.*@gmail\\.com$": [ "%a", [ "outbound-proxy.mlsmtp.example" ] ]
}
```
*In the above example, mail delivered to example@gmail.com will be
delivered to example@gmail.com through outbound-proxy.mlsmtp.example.*

#### Alternate Rules File
To read transport rules from a nonstandard file, specify the following
setting in `default.json`.
```json
{
  "transport": {
    "rules_file": "conf/alternate_transport_rules.json"
  }
}
```

## Transport Authorization
Rules to permit/deny email delivery are specified in `transport_authorization.json`.
This JSON file contains an array of hashes containing rules. Whether an email is
authorized or not is determined by the first rule it matches, and if the email
matches no rules, it is not authorized by default. The format of the rules file is
as follows.
```json
[
  {
    "rule": "allow",
    "auth_exempt": true,
    "match_by": {
    },
    "determine_by": {
    }
  }
```
An email matches the rule if it matches all of the parameters in `"match_by"`, and
if it matches, its status is determined by the parameters in `"determine_by"`. If
the rule is set to `allow`, it will be permitted if its status is positively
determined, and denied if not. If the rule is set to `deny`, it will be denied if
its status is positively determined, and permitted if not. If `"auth_exempt"` is set
to true and an email is permitted by the rule, the email will be exempt from extra
authorization (SPF, DKIM, etc.). The `"match_by"` and `"determine_by"` fields accept
the following parameters.
* `"from_ip"`: Array of CIDR notation IP addresses; check passes if the sending server's
IP is included in any of the specified IP blocks.
    * `"from_ip": [ "127.0.0.1/32", "::1/128" ]`
* `"from_email"`: Regex of the sender's email address
    * `"from_email": "^.*@localhost$"`
* `"to_email"`: Regex of the recipient's email address
    * `"to_email": "^.*@localhost$"`
* `"auth"`: Email account that the sender has successfully authenticated as
    * This parameter supports substituting `%u`, `%d`, `%a` for the user name,
email domain, and email address of the sender's email address.
    * `"auth": "%u"`

#### Examples
Allow any emails originating from localhost
```json
[
  {
    "rule": "allow",
    "auth_exempt": true,
    "match_by": {
      "from_ip": [ "127.0.0.1/32", "::1/128" ]
    },
    "determine_by": {
    }
  }
]
```
Require a user to be authenticated as the account he is trying to send email from
<br>
*This rule, for example, requires you to log in as bob to send email as bob@mlsmtp.example.*
```json
[
  {
    "rule": "allow",
    "auth_exempt": true,
    "match_by": {
      "from_email": "^.*@mlsmtp\\.example$"
    },
    "determine_by": {
      "auth": "%u"
    }
  }
]
```
Permit email to be delivered to local accounts without authentication
<br>
*Note the absense of the auth_exempt parameter -- this means inbound emails permitted
under this rule must pass authentication checks like SPF.*
```json
[
  {
    "rule": "allow",
    "match_by": {
      "to_email": "^.*@mlsmtp\\.example$"
    },
    "determine_by": {
    }
  }
]
```

#### Alternate Auth File
To read transport authentication rules from a nonstandard file, specify the following
setting in `default.json`.
```json
{
  "transport": {
    "authorization_file": "conf/alternate_transport_authorization.json"
  }
}
```
