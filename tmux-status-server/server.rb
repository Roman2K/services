require 'values_server'

module TmuxStatus
  PORTS_RANGES = [8000..8999, 3000..3999]

  class << self
    def cpu
      `ps -U #{Process.uid} -e -o %cpu,comm`.
        split("\n").
        drop(1).
        map { |line| line.split(" ", 2) }.
        sort_by { |pct,| -pct.to_f }[0,3].
        map { |pct, cmd| "#{pct} #{short_cmd(cmd)[0,7]}".rstrip }.
        join(", ")
    end

    def ports
      `lsof -l -P -n -i TCP -s TCP:LISTEN`.
        split("\n").
        drop(1).
        grep(/.*:(\d+) \(LISTEN\)/) { $1.to_i }.
        uniq.
        select { |port| PORTS_RANGES.any? { |r| r.include? port } }.
        sort.
        join(", ")
    end

  private

    def short_cmd(cmd)
      if cmd[0] != ?/
        return cmd
      end
      exe, rest = cmd.split(" ", 2)
      [File.basename(exe), rest].compact.join(" ")
    end
  end
end

ValuesServer::Server.new '/tmp/tmux_status.sock',
  'time'  => lambda { `date` },
  'cpu'   => ValuesServer::Cache.new(5).value { TmuxStatus.cpu }.method(:get),
  'ports' => ValuesServer::Cache.new(5).value { TmuxStatus.ports }.method(:get)
