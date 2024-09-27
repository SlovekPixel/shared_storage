defmodule SharedStorage.Messages.ResponseMessages do
  @moduledoc """
  A module for storing messages used in responses.
  """

  def success_message(operation) when is_atom(operation) or is_binary(operation) do
    "#{to_string(operation)} successfully."
  end

  def error_message(operation) when is_atom(operation) or is_binary(operation) do
    "Error occurred during #{to_string(operation)}."
  end

  def owner_mismatch, do: "Owner mismatch. Unable to perform a transaction on a ticket."
  def ticket_already_blocked, do: "The Ticket has already been blocked."
  def ticket_not_blocked, do: "The ticket is not blocked."
  def unknown_error, do: "An unknown error occurred."
end