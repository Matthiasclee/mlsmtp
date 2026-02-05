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
