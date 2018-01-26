defmodule Ring do
  def create_processes(n) do
    1..n |> Enum.map(fn _ -> spawn(fn -> loop() end) end)
  end

  def loop do
    receive do
      {:link, link_to} when is_pid(link_to) ->
        Process.link(link_to)
        loop()
      :crash ->
        raise "Crashed"
    end
  end

  # Setup aggregator
  def link_processes(procs), do: link_processes(procs, [])

  # Matches only if there are at least two elements in a list
  def link_processes([proc_1, proc_2 | rest], linked_processes) do
    send(proc_1, {:link, proc_2})
    link_processes([proc_2 | rest], [proc_1|linked_processes])
  end

  # Matches when only a single element in the list and links the first proc to
  # the the last proc in order to create the ring. Interesting to note that
  # there are no matching functions if a user were to pass an empty list for
  # procs.
  def link_processes([proc | []], linked_processes) do
    first_process = linked_processes |> List.last
    send(proc, {:link, first_process})
    :ok
  end
end
