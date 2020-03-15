import IO.ANSI, only: [green: 0, default_color: 0]

defmodule Helper do
  def camelize(<<first::utf8, rest::binary>>) do
    String.upcase(<<first::utf8>>) <> String.downcase(rest)
  end
end

{name, _} = System.cmd("whoami", [])

IO.puts("""

Welcome to IEx #{green()} #{Helper.camelize(name)} #{default_color()}
""")

IEx.configure(
  alive_prompt: "%prefix(%node):%counter>",
  default_prompt: "%prefix:%counter>",
  inspect: [pretty: true, char_lists: :as_lists, limit: :infinity],
  history_size: -1,
  colors: [
    ls_directory: :cyan,
    ls_device: :yellow,
    doc_code: :green,
    doc_inline_code: :magenta,
    doc_headings: [:cyan, :underline],
    doc_title: [:cyan, :bright, :underline],
    eval_result: [:cyan, :bright]
  ]
)

import_file_if_available(".secret.exs")
