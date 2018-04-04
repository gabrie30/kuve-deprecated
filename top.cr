class Top
  def initialize(context_group : String, resource : String)
    @resource = resource
    @context_group = context_group
  end

  def contexts
    JSON.parse(File.open("/usr/local/bin/kuve_conf.json"))["rawcontexts"]["#{@context_group}"]
  end

  def run_top
    puts
    contexts.each do |con|
      puts "---------------- Running Top for #{@resource}s in: #{con} ----------------"
      puts

      if @resource == "node"
        puts `kubectl top #{@resource} --context=#{con}`
      elsif @resource == "pod"
        puts `kubectl top #{@resource} --all-namespaces --context=#{con} | sort -k 5 | head -30`
      end
      puts
    end

    puts "$ kubectl top #{@resource}"
  end
end
