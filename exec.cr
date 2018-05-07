class Exec
  def initialize(namespace : String, chosen_shell : String)
    @namespace = namespace

    if chosen_shell == "false"
      @shell = default_shell
    else
      @shell = chosen_shell
    end
  end

  def default_shell
    # If no context flag is supplied just use default
    JSON.parse(File.open("/usr/local/bin/kuve_conf.json"))["shell"]["exec-default"].to_s
  end

  def exec_into_pod
    pod_name = get_pod_name.chomp
    env = `kubectl config current-context`
    puts "###### Running the following command in  #{env.chomp}  ######"
    puts ""
    puts "$ kubectl exec -it #{pod_name} -n #{@namespace} -- #{@shell}"
    puts ""
    system("kubectl exec -it #{pod_name} -n #{@namespace} -- #{@shell}")
  end

  def get_pod_name
    `kubectl get pods -n #{@namespace} --no-headers | head -n1 | cut -d " " -f1`
  end
end
