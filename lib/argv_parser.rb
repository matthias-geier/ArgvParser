
class ArgvParser
  def initialize
    @args = Hash.new
    @aliases = Hash.new
    @l_short = 0
    @l_long = 0
  end

  def hook(short, long, type, options)
    raise ArgumentError.new("short is nil") if not short

    @args[short.downcase] = {
      :long => long,
      :type => type,
      :opts => options,
      :yield => Proc.new {|v| yield(v) }
    }
    @l_short = short.length + 1 if @l_short < short.length + 1
    @l_long = long.length + 1 if @l_long < long.length + 1
  end

  def help
    puts "Help:"
    @args.each do |k,v|
      spaces = ""
      (@l_short-k.length).times { spaces << " " }
      spaces2 = ""
      (@l_long-v[:long].length).times { spaces2 << " " }
      puts "#{k}#{spaces} #{v[:long]}#{spaces2} mandatory: #{v[:opts][:mandatory] == true}"
    end
  end

  def parse!(args)
    begin
    executor = Array.new
    i = 0

    @mandatory = Array.new
    @args.each do |k,v|
      @mandatory.push k if v[:opts][:mandatory]
    end

    while i < args.length
      if v = @args[args[i].downcase]
        @mandatory.delete args[i].downcase
        
        n = nil
        if v[:type]
          raise ArgumentError.new("argument for #{args[i].downcase} missing") if i+1 >= args.length
          i += 1
          case v[:type].to_s
            when "Array"
              n = args[i].split ','
            when "Float"
              n = args[i].to_f
            when "Integer"
              n = args[i].to_i
            else
              n = $1 if args[i] =~ /^\"?(.*)\"?$/
            end
        end
        executor.push [v[:yield], n]
      else
        raise ArgumentError.new("argument #{args[i].downcase} unknown")
      end
      i += 1
    end

    if not @mandatory.empty?
      raise ArgumentError.new("mandatory #{@mandatory[0]} is missing")
    end
    
    if executor.empty?
      help
    else
      executor.each do |e|
        e[0].call(e[1])
      end
    end
    rescue Exception => e
      puts "#{e.class}: #{e.message}\n"
      help
    end
  end
end
