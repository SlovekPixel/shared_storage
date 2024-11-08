defmodule SharedStorage.CORS do
  use Corsica.Router,
      origins: ["http://foo.com"],
      allow_credentials: true,
      max_age: 600

  resource "/public/*", origins: "*"
  resource "/*"
end