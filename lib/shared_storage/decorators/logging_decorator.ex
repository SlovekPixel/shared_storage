defmodule LoggingDecorator do
  use Decorator.Define, [log: 0]
  alias SharedStorage.{Repo, LockLogs}

  def log(body, context) do
    quote do
      response = unquote(body)

      owner = response.lock.owner
      ticket = response.lock.ticket
      message = response.message
      wasted_time = response.wastedTime

      if (response.isError == false) do
        log_data = %{
          method: Atom.to_string(unquote(context.name)),
          ticket: ticket,
          owner: owner,
          message: message,
          wasted_time: wasted_time,
        }

        changeset = LockLogs.changeset(%LockLogs{}, log_data)
        case Repo.insert(changeset) do
          {:ok, _log} ->
            IO.puts("Log saved successfully.")
          {:error, changeset} ->
            IO.inspect(changeset.errors, label: "Error saving log")
        end
      end

      response
    end
  end
end
