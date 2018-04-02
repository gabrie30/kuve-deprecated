class Crashed
  def initialize(context_group : String)
    @data = Array(String).new
    @context_group = context_group
  end

  def contexts
    # If no context flag is supplied just use default
    JSON.parse(File.open("/usr/local/bin/kuve_conf.json"))["rawcontexts"]["#{@context_group}"]
  end

  def get_all_crashed_pods
    puts
    contexts.each do |con|
      puts "---------------- Checking Non Running Pods in: #{con} ----------------"
      puts
      puts `kubectl get pods --context=#{con} --all-namespaces --no-headers | grep -v Running`
      puts
    end
  end
end
