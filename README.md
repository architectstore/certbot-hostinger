# certbot-hostinger

Container image to issue/renew Let's Encrypt certificates using DNS-01 via Hostinger DNS (certbot-dns-hostinger). [attached_file:1]

This is intended to run as a Kubernetes Job/CronJob and then publish the resulting cert/key (or sync into a Kubernetes TLS Secret) for Traefik (or any ingress) to use. [conversation_history]

## What this image does

- Runs `certbot certonly` with `dns-hostinger` authenticator (DNS-01). [attached_file:1]
- Creates and deletes the `_acme-challenge` TXT record in your Hostinger DNS zone automatically (provided by the `certbot-dns-hostinger` plugin). [attached_file:1]

## Requirements

### Hostinger API token

Create an API token in Hostinger hPanel with DNS management permissions (as per the plugin documentation). [attached_file:1]

### Credentials file (mounted)

The plugin expects an INI file at:

`/etc/letsencrypt/hostinger/credentials.ini` [attached_file:1]

Example contents:

```

dns_hostinger_api_token = <your-api-token>

```

Recommended permissions: `chmod 600 credentials.ini`. [attached_file:1]

### Persistent storage

For renewal automation you generally want `/etc/letsencrypt` persisted (PVC in Kubernetes) so Certbot keeps:
- Account registration.
- Renewal configuration.
- Previous cert lineage. [conversation_history]

## Build

From repo root:

```

./scripts/build.sh

```

This builds and tags:
- `architectstore/certbot-hostinger:latest`
- `architectstore/certbot-hostinger:<ddmmyyyy>` (auto-generated tag) [conversation_history]

## Push to Docker Hub

```

docker login
./scripts/biuld.sh

```


## Usage (local test)

### Issue a staging certificate

```

docker run --rm \
-e LE_EMAIL=you@costareis.eu \
-e LE_DOMAIN=ha.costareis.eu \
-e LE_ENV=staging \
-e PROPAGATION_SECONDS=180 \
-v "$PWD/letsencrypt:/etc/letsencrypt" \
  -v "$PWD/credentials.ini:/etc/letsencrypt/hostinger/credentials.ini:ro" \
architectstore/certbot-hostinger:latest issue

```

### Issue a production certificate

Same as above but omit `LE_ENV=staging` (or set `LE_ENV=prod`). [conversation_history]

### Renew

```

docker run --rm \
-e LE_ENV=prod \
-v "$PWD/letsencrypt:/etc/letsencrypt" \
  -v "$PWD/credentials.ini:/etc/letsencrypt/hostinger/credentials.ini:ro" \
architectstore/certbot-hostinger:latest renew

```

## Environment variables

- `LE_EMAIL` (required for `issue`). [conversation_history]
- `LE_DOMAIN` (required for `issue`). [conversation_history]
- `LE_ENV` (optional): `prod` (default) or `staging`. [conversation_history]
- `PROPAGATION_SECONDS` (optional): default `180`. [conversation_history]

## Notes / gotchas

- This repo only handles certificate issuance/renewal; Traefik should consume the cert from a Kubernetes TLS Secret (recommended) or other distribution method. [conversation_history]
- Keep the Hostinger credentials in a Kubernetes Secret mounted as a file; do not bake credentials into the image. [attached_file:1]
```

