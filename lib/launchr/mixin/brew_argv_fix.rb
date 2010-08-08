module FixHomebrewArgvExtension

  def flag? flag
    options = select {|arg| arg[0..0] == '-'}
    
    options.each do |arg|
      return true if arg == flag
      next if arg[1..1] == '-'
      return true if arg.include? flag[2..2]
    end
    return false
  end
end

ARGV.extend(FixHomebrewArgvExtension)

