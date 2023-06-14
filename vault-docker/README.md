# Consul-Template Plugin: string2files

- This is used to use that plugin in the vault injector to save the secrets to seperate files

docker buildx create --use --name vault-injector-plugin
docker buildx build --build-arg DOCKER_USERNAME=<username> --build-arg DOCKER_PASSWORD=<password> --platform linux/amd64,linux/arm64 --push -t dubizzledotcom/vault-injector-plugin:<tag> .