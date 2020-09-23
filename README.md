# RegistryCleaner

Service which cleans a registry of old tags. When there are more than `MAX_PER_TAG` tags of each base_tag the oldest one will be removed until there are only `MAX_PER_TAG` left. The following configuration will do that operation to the following image tags:

```sh
registry.example.com/<image>:prod-*
registry.example.com/<image>:test-*
```

```sh
# Registry host
REGISTRY_HOST=registry.example.com
# Registry protocol, (http or https)
PROTO=https
# Tags to delete.
TAGS=prod,test
# Registry username
REGISTRY_USERNAME=username
# Registry password
REGISTRY_PASSWORD=password
# Max available tags per image (All else are deleted starting with the oldest)
MAX_PER_TAG=10
# Run every 60 seconds
RUN_EVERY=60
```

## Development

During development, provide the correct environment variables and run the code with the following commands:

```sh
# Run once
mix run -e RegistryCleaner.main
# Run as a service
iex -S mix
```

## Deployment

Published at docker hub with name [`jonaskop/registry_cleaner`](https://hub.docker.com/r/jonaskop/registry_cleaner)

To deploy, run the deployment script `./deploy.sh`.
