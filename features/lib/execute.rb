require 'open3'

def execute(command)
  Open3.popen3(command) do |stdin, stdout, stderr, thread|
    puts stdout.read
    puts stderr.read
    exit_status = thread.value.to_i
  end
end
