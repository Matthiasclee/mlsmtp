# Mail Lists

## Using mlsmtplist
#### Config File
All `mlsmtplist` commands must have the MLSMTP configuration file
specified in the `--conf` parameter as follows. Assume that this parameter
is present in every other `mlsmtplist` command in this document.
```
mlsmtplist --conf=/opt/example/conf/default.json
```

#### Showing All Lists
All mail lists can be shown with the `--listall` argument.
```
$ mlsmtplist --listall
1: staff@company.example
2: management@company.example
```

#### Creating and Deleting a List
Mail lists can be created with `mlsmtplist` with the `--create` argument,
specifying the email address of the list to be created.
```
$ mlsmtplist staff@company.example --create
```
Similarly, a mail list can be deleted with the `--delete` argument.

```
$ mlsmtplist staff@company.example --delete
```

#### Listing Members
The members of a mail list can be listed with the `--listmembers` argument.
```
$ mlsmtplist staff@company.example --listmembers
bob@company.example
alice@company.example
```

#### Modifying Membership
A user can be added to a mail list with the `--addmember` argument.
```
$ mlsmtplist staff@company.example --addmember john@company.example
```
Similarly, a user can be removed with the `--removemember` argument.
```
$ mlsmtplist staff@company.example --removemember matthew@company.example
```

## Other Mail List Settings
#### Recursion
The max recursion depth for an email delivered to an email list is set in `default.json`.
```json
{
  "max_list_recursion": 0
}
```
*In the above example, an email will not be delivered to an email list specified in an
email list. If it was set to one, the mail would be delivered to an address in an email
list in an email list.*

#### Security
Email lists accessible to everyone are generally insecure, so it is recommended to use
[transport authorization rules](docs/transport.md) to restrict access to send mail to an
email list.
```json
[
  {
    "rule": "allow",
    "auth_exempt": true,
    "match_by": {
      "to_email": "^staff@company\\.example$"
    },
    "determine_by": {
    }
  }
]
```
