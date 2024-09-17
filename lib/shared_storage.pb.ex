defmodule LockService.LockRequest do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :owner, 1, type: :string
  field :ticket, 2, type: :string
  field :lifetime, 10, type: :int32
end

defmodule LockService.LockRequestNoTime do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :owner, 1, type: :string
  field :ticket, 2, type: :string
end

defmodule LockService.LockRequestList do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :owner, 1, type: :string
  field :tickets, 3, repeated: true, type: :string
  field :lifetime, 10, type: :int32
end

defmodule LockService.LockRequestNoTimeList do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :owner, 1, type: :string
  field :tickets, 3, repeated: true, type: :string
end

defmodule LockService.LockResponse do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :isError, 3, type: :bool
  field :lock, 6, type: LockService.LockRequest
  field :wastedTime, 17, type: :int32
  field :message, 20, type: :string
end

defmodule LockService.LockResponseList do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :isError, 3, type: :bool
  field :responses, 6, repeated: true, type: LockService.LockResponse
  field :wastedTime, 17, type: :int32
end

defmodule LockService.LockResponseNoTime do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :isError, 3, type: :bool
  field :lock, 6, type: LockService.LockRequestNoTime
  field :wastedTime, 17, type: :int32
  field :message, 20, type: :string
end

defmodule LockService.LockResponseNoTimeList do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :isError, 3, type: :bool
  field :responses, 6, repeated: true, type: LockService.LockRequestNoTime
  field :wastedTime, 17, type: :int32
end

defmodule LockService.PollResponse do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :isBlocked, 1, type: :bool
  field :isError, 3, type: :bool
  field :lock, 6, type: LockService.LockRequestNoTime
  field :wastedTime, 17, type: :int32
end

defmodule LockService.PollResponseList do
  @moduledoc false

  use Protobuf, syntax: :proto3, protoc_gen_elixir_version: "0.12.0"

  field :responses, 1, repeated: true, type: LockService.PollResponse
  field :isBlocked, 3, type: :bool
end

defmodule LockService.LockService.Service do
  @moduledoc false

  use GRPC.Service, name: "lockService.LockService", protoc_gen_elixir_version: "0.12.0"

  rpc :AcquireLock, LockService.LockRequest, LockService.LockResponse

  rpc :ReleaseLock, LockService.LockRequestNoTime, LockService.LockResponseNoTime

  rpc :ExtendLock, LockService.LockRequest, LockService.LockResponse

  rpc :PersistLock, LockService.LockRequestNoTime, LockService.LockResponseNoTime

  rpc :PollLock, LockService.LockRequestNoTime, LockService.PollResponse

  rpc :PollLockList, LockService.LockRequestNoTimeList, LockService.PollResponseList

  rpc :EnsureLock, LockService.LockRequest, LockService.LockResponse
end

defmodule LockService.LockService.Stub do
  @moduledoc false

  use GRPC.Stub, service: LockService.LockService.Service
end