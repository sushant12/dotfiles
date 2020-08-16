import IO.ANSI, only: [green: 0, default_color: 0]

defmodule Helper do
  def camelize(<<first::utf8, rest::binary>>) do
    String.upcase(<<first::utf8>>) <> String.downcase(rest)
  end
end

defmodule History do
  def search(term) do
    load_history()
    |> Stream.filter(&String.match?(&1, ~r/#{term}/))
    |> Enum.reverse()
    |> Stream.with_index(1)
    |> Enum.each(fn {value, index} ->
      IO.write("#{index}  ")
      IO.write(String.replace(value, term, "#{IO.ANSI.red()}#{term}#{IO.ANSI.default_color()}"))
    end)
  end

  def search do
    load_history()
    |> Enum.reverse()
    |> Stream.with_index(1)
    |> Enum.each(fn {value, index} ->
      IO.write("#{index}  #{value}")
    end)
  end

  defp load_history, do: :group_history.load() |> Stream.map(&List.to_string/1)
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
