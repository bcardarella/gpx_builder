defmodule GPXBuilder do
  def parse_waypoints(file_path, name_modifier) do
    File.read!(file_path)
    |> String.split("\r\n", trim: true)
    |> Enum.map(fn row ->
      [id, name, color, light, lat, lon, gov_num] = String.split(row, ",")

      desc =
        [color, light, "Gov: #{gov_num}"]
        |> Enum.reject(fn e -> e == "" end)
        |> Enum.join("\n")

      %{
        name: name_modifier.(id, name),
        desc: desc,
        lat: convert_degrees_to_decimal(lat),
        lon: convert_degrees_to_decimal(lon)
      }
    end)
  end

  def render_waypoints(waypoints) do
    EEx.eval_file("waypoints.gpx.eex", [assigns: [waypoints: waypoints]], trim: true)
  end

  defp convert_degrees_to_decimal(full_degrees) do
    [_, degrees, seconds] = Regex.run(~r/(-?\d+).(.*)/, full_degrees)

    degrees = String.to_integer(degrees)
    seconds = String.to_float(seconds) / 60

    if degrees < 0 do
      (degrees * -1 + seconds) * -1
    else
      degrees + seconds
    end
    |> :erlang.float_to_binary(decimals: 6)
  end

  def write(content, path) do
    File.write!(path, content)

    path
  end

  def build(bayname) do
    output_path = "output/#{bayname}-waypoints.gpx"

    "data/#{bayname}.csv"
    |> GPXBuilder.parse_waypoints(fn id, name ->
      "#{String.upcase(bayname)}-#{id} #{name}"
    end)
    |> GPXBuilder.render_waypoints()
    |> GPXBuilder.write(output_path)
    |> GPXBuilder.validate(bayname)

    IO.puts("built #{bayname} at #{output_path}")
  end

  def validate(gpx_path, bayname) do
    saxcount_path = System.find_executable("SAXCount")

    port =
      Port.open({:spawn_executable, saxcount_path}, [
        :binary,
        :exit_status,
        args: ["-v=always", "-n", "-s", "-f", gpx_path]
      ])

    receive do
      {^port, {:exit_status, 0}} ->
        IO.puts("#{bayname} validation passed!")

      {^port, {:exit_status, _code}} ->
        IO.puts("#{bayname} failed, for error list run:\nSAXCount -v=always -s -f #{gpx_path}")
    end
  end
end

GPXBuilder.build("hb")
GPXBuilder.build("mb")
GPXBuilder.build("sb")
