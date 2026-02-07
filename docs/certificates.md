# Certificates
Certificates are used in MLSMTP for STARTTLS and Implicit TLS, and for DKIM signing.

## Keypair Configuration

#### Keypair (key + certificate)
A keypair consisting of an RSA key and certificate is configured in `default.json` as follows.
This is used for STARTTLS and Implicit TLS for servers.
```json
{
  "certificates": {
    "default": {
      "cert_path": "ssl/server.crt",
      "key_path": "ssl/server.key"
    }
  }
}
```

#### Key Only
A lone RSA key is used for DKIM signing and is configured as follows in `default.json`.

```json
{
  "certificates": {
    "dkim": {
      "key_path": "ssl/dkim.key"
    }
  }
}
```
