defmodule SharedStorage.Validators.LockValidator do
  import Ecto.Changeset
  alias SharedStorage.{
    LockRequestNoTime,
    PollResponse,
  }

  @doc """
  Input Data Validation.
  """

  def validate_lifetime(params) do
    input = %{
      "owner" => params.owner,
      "ticket" => params.ticket,
      "lifetime" => params.lifetime,
    }

    rules = %{
      "owner" => [required: true, type: :string],
      "ticket" => [required: true, type: :string],
      "lifetime" => [required: true, type: :number]
    }

    case Validate.validate(input, rules) do
      {:ok, data} -> {:ok, data}
      {:error, errors} ->
        response = %PollResponse{
          isError: true,
          isBlocked: true,
          lock: %LockRequestNoTime{
            owner: params.owner,
            ticket: params.ticket
          },
          message: Enum.join(errors, ", ")
        }

        {:error, response}
    end
  end

  def validate_no_lifetime(params) do
    input = %{
      "owner" => params.owner,
      "ticket" => params.ticket
    }

    rules = %{
      "owner" => [required: true, type: :string],
      "ticket" => [required: true, type: :string],
    }

    case Validate.validate(input, rules) do
      {:ok, data} -> {:ok, data}
      {:error, errors} ->
        formatted_errors = Enum.map(errors, fn %Validate.Validator.Error{path: path, message: message, rule: _rule} ->
          "#{Enum.join(path, ".")}: #{message}"
        end)
        IO.puts(Enum.join(formatted_errors, ", "))

        response = %PollResponse{
          isError: true,
          isBlocked: true,
          lock: %LockRequestNoTime{
            owner: params.owner,
            ticket: params.ticket
          },
          message: Enum.join(formatted_errors, ", ")
        }

        {:error, response}
    end
  end

  def validate_poll(params) do
    input = %{
      "owner" => params.owner,
      "ticket" => params.ticket
    }

    rules = %{
      "owner" => [required: true, type: :string],
      "ticket" => [required: true, type: :string],
    }

    case Validate.validate(input, rules) do
      {:ok, _} -> :ok
      {:error, errors} ->
        formatted_errors = Enum.map(errors, fn %Validate.Validator.Error{path: path, message: message, rule: _rule} ->
          "#{Enum.join(path, ".")}: #{message}"
        end)

        response = %PollResponse{
          isError: true,
          isBlocked: true,
          lock: %LockRequestNoTime{
            owner: params.owner,
            ticket: params.ticket
          },
          message: Enum.join(formatted_errors, ", ")
        }

        {:error, response}
    end
  end
end