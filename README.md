# SharedStorage
### A standalone service based on redis to provide fast ttl-driven data storage over grpc.

## Start
To start app:
* Run `mix setup` to install and setup dependencies;
* Start Phoenix endpoint with `mix phx.server`. 
* Check API with grpc-reflection.

## Proto
#### Generate proto files: `generate_protos.sh`
``` bash
protoc --elixir_out=gen_descriptors=true,plugins=grpc:. "./lib/protos/shared_storage.proto"
```

## Docker
#### Assemble the whole project:
``` bash
$ docker-compose up --build
```
