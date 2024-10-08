#defmodule LoggingDecorator do
#  use Decorator.Define, [log: 0]
#  alias SharedStorage.{Repo, LockLogs}
#  alias SharedStorage.{
#    LockRequest,
#    LockResponse,
#  }
#
#  # Функция декоратора
#  def log(body, context) do
#    quote do
#      IO.puts("Function called: " <> Atom.to_string(unquote(context.name)))
#      [request, _stream] = unquote(body)
#
#      IO.puts("Request ticket: " <> request.ticket)
#      IO.puts("Request owner: " <> request.owner)
#    end
#  end
#end
