defmodule SharedStorage.Validators.LockValidator do
  @moduledoc """
  Input Data Validation.
  """

#  import Ecto.Changeset
  alias SharedStorage.{
    LockRequest,
    LockRequestNoTime,
    PollResponse,
    LockResponse,
    LockResponseNoTime,
    PollResponseList,
  }

  @common_rules %{
    "owner" => [required: true, type: :string, uuid: true],
    "ticket" => [required: true, type: :string, uuid: true]
  }

  defp format_errors(errors) do
    Enum.map(errors, fn %Validate.Validator.Error{path: path, message: message, rule: _rule} ->
      "#{Enum.join(path, ".")}: #{message}"
    end)
  end

  def validate_lock_request(params) do
    input = %{
      "owner" => params.owner,
      "ticket" => params.ticket,
      "lifetime" => params.lifetime,
    }

    rules = Map.put(@common_rules, "lifetime", [required: true, type: :number])

    case Validate.validate(input, rules) do
      {:ok, _} -> :ok
      {:error, errors} ->
        formatted_errors = format_errors(errors)

        response = %LockResponse{
          isError: true,
          lock: %LockRequest{
            owner: params.owner,
            ticket: params.ticket,
            lifetime: params.lifetime
          },
          message: Enum.join(formatted_errors, ", ")
        }

        {:error, response}
    end
  end

  def validate_lock_request_no_time(params) do
    input = %{
      "owner" => params.owner,
      "ticket" => params.ticket
    }

    case Validate.validate(input, @common_rules) do
      {:ok, _} -> :ok
      {:error, errors} ->
        formatted_errors = format_errors(errors)

        response = %LockResponseNoTime{
          isError: true,
          lock: %LockRequestNoTime{
            owner: params.owner,
            ticket: params.ticket
          },
          message: Enum.join(formatted_errors, ", ")
        }

        {:error, response}
    end
  end

  def validate_poll_request(params) do
    input = %{
      "owner" => params.owner,
      "ticket" => params.ticket
    }

    case Validate.validate(input, @common_rules) do
      {:ok, _} -> :ok
      {:error, errors} ->
        formatted_errors = format_errors(errors)

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

  def validate_lock_request_no_time_list(params) do
    input = %{
      "owner" => params.owner,
      "tickets" => params.tickets
    }

    rules = %{
      "owner" => [required: true, type: :string, uuid: true],
      "tickets" => [
        required: true,
        type: :list,
        list: [required: true, type: :string, uuid: true],
      ],
    }

    case Validate.validate(input, rules) do
      {:ok, _} -> :ok
      {:error, errors} ->
        responses = Enum.map(params.tickets, fn ticket ->
          lock_data = %LockRequestNoTime{
            owner: params.owner,
            ticket: ticket
          }

          %PollResponse{
            isBlocked: true,
            isError: true,
            lock: lock_data
          }
        end)

        formatted_errors = format_errors(errors)
        poll_response_list = %PollResponseList{
          responses: responses,
          isBlocked: true,
          isError: true,
          message: Enum.join(formatted_errors, ", ")
        }

        {:error, poll_response_list}
    end
  end
end