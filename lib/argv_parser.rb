
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
      :yield => Proc.new {|p, v| yield(p, v) }
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
      puts "#{k}#{spaces} #{v[:long]}#{spaces2} mandatory: \
        #{v[:opts][:mandatory] == true}"
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
      k = args[i].downcase
      v = i+1 < args.length ? args[i+1] : nil
      hook = @args[k]
      if !hook and !v
        hook = @args["--"]
        v = k
        k = "--"
      end

      if hook
        @mandatory.delete(k)

        n = nil
        if hook[:type]
          unless v
            raise ArgumentError.new("argument for #{k} missing")
          end
          i += 1
          case hook[:type].to_s
            when "Array"
              n = v.split ','
            when "Float"
              n = v.to_f
            when "Integer"
              n = v.to_i
            else
              n = $1 if v =~ /^\"?(.*)\"?$/
            end
        end
        executor.push [hook[:yield], n]
      else
        raise ArgumentError.new("argument #{k} unknown")
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
        e[0].call(self, e[1])
      end
    end
    rescue Exception => e
      puts "#{e.class}: #{e.message}\n"
      help
    end
  end
end
