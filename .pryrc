Pry.config.history.file = ".irb_history"
Pry.config.pager = false
Pry.config.prompt = [
  proc { "> " },
  proc { ".." }
]

$:.unshift File.dirname(__FILE__)

module Kernel
  # make an alias of the original require
  alias_method :original_require, :require

  # rewrite require
  def require name
    begin
      original_require name
    rescue LoadError => e
      begin
        original_require File.join(name, File.basename(name))
      rescue LoadError => j
        raise j
      end
    end
  end
end

Pry::Commands.block_command "rl", "require last package" do
  lastreq = Pry.history.instance_variable_get(:@history).grep(/^\s*require/)[-1]
  unless lastreq
    output.puts "no require history"
  else
    output.puts lastreq
    eval lastreq
  end
end

Pry::Commands.block_command "import", "require package" do |x|
  require x
end