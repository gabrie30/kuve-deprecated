class CrashedLogs
  def initialize(namespace : String)
    @namespace = namespace
  end

  # Works only for the first container in the deployments
  def get_logs
    # Get container name
    deployment = JSON.parse(get_deployment)
    container_name = deployment["items"].first["spec"]["template"]["spec"]["containers"].first["name"]

    # Get all pods with restarts
    pods_with_restarts = `kubectl get pods -n #{@namespace} --no-headers | awk -v x=1 '$4 >= x' | awk '{print $1}'`
    # Run logs on all pods with restarts

    pods = pods_with_restarts.strip.split("\n").select { |p| p != "" }

    if pods.size >= 1
      puts
      pods.each do |pod|
        puts "------------------------- POD LOGS: #{pod} ------------------------------"
        puts
        puts
        puts `kubectl logs #{pod} -n #{@namespace} -c #{container_name} --previous`
        puts
        puts
      end
      puts "$ kubectl logs <pod> -n #{@namespace} -c #{container_name} --previous"
    else
      puts "No pods with restarts in namespace: #{@namespace}"
    end
  end

  def get_deployment
    `kubectl get deployment -n #{@namespace} -o=json`
  end
end
