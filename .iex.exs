import IO.ANSI, only: [green: 0, default_color: 0]

defmodule Helper do
  def camelize(<<first::utf8, rest::binary>>) do
    String.upcase(<<first::utf8>>) <> String.downcase(rest)
  end
end

defmodule History do
  def search do
    load_history()
    |> Enum.with_index(1)
    |> Enum.each(fn {value, index} ->
      IO.write("#{index}  #{value}")
    end)
  end

  def search(term) do
    load_history()
    |> Enum.filter(&String.match?(&1, ~r/#{term}/))
    |> Enum.with_index(1)
    |> Enum.each(fn {value, index} ->
      IO.write("#{index}  ")
      IO.write(String.replace(value, term, "#{IO.ANSI.red()}#{term}#{IO.ANSI.default_color()}"))
    end)
  end

  def search(term, opts) do
    history = load_history()
    history_count = Enum.count(history)

    history
    |> get_match_indices(term)
    |> maybe_add_contexts(opts, history_count)
    |> group_ranges()
    |> Enum.each(fn range_list ->
      parse_range(range_list)
      |> Enum.each(fn match_index ->
        if match_index < history_count do
          txt = Enum.at(history, match_index)

          IO.write("#{match_index}  ")

          IO.write(String.replace(txt, term, "#{IO.ANSI.red()}#{term}#{IO.ANSI.default_color()}"))
        end
      end)

      IO.write("#{IO.ANSI.red()}--- #{IO.ANSI.default_color()} \n")
    end)
  end

  defp group_ranges([head | rest]) do
    Enum.reduce(rest, {head, [], []}, fn current, {prev, group, grouped} ->
      if Range.disjoint?(current, prev) do
        {current, [current], [Enum.reverse(group) | grouped]}
      else
        {current, [current | group], grouped}
      end
    end)
    |> elem(2)
    |> Enum.reverse()
  end

  defp get_match_indices(history, term) do
    history
    |> Enum.with_index()
    |> Enum.flat_map(fn {element, index} ->
      case String.match?(element, ~r/#{term}/) do
        true -> [index]
        false -> []
      end
    end)
  end

  defp maybe_add_contexts(match_indices, opts, history_count) do
    context_a = Keyword.get(opts, :A, 0)
    context_b = Keyword.get(opts, :B, 0)

    match_indices
    |> Enum.map(fn index ->
      upper_bound(index, context_b)..lower_bound(index, context_a, history_count)
    end)
  end

  defp upper_bound(index, 0), do: index

  defp upper_bound(index, context_b) do
    potential_index = index - context_b

    if potential_index < 0 do
      0
    else
      potential_index
    end
  end

  defp lower_bound(index, 0, _), do: index

  defp lower_bound(index, context_a, history_count) do
    potential_index = index + context_a

    if potential_index > history_count do
      history_count
    else
      potential_index
    end
  end

  defp parse_range(range_list) do
    Enum.map(range_list, &Enum.to_list/1)
    |> List.flatten()
    |> Enum.uniq()
  end

  defp load_history do
    :group_history.load()
    |> Enum.map(&List.to_string/1)
    |> Enum.reverse()
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
