#!/bin/bash

PROTOS=("
    ./lib/protos/shared_storage.proto
")

for file in $PROTOS; do
  protoc --elixir_out=gen_descriptors=true,plugins=grpc:. $file
done