require "colorize"

class Exposed
  def initialize(context_group : String)
    @context_group = context_group
  end

  def contexts
    # If no context flag is supplied just use default
    JSON.parse(File.open("/usr/local/bin/kuve_conf.json"))["rawcontexts"][@context_group]
  end

  def get_all_exposed
    contexts.each do |context|
      puts "--------------------------------------- Externally Endpoints in #{context} ---------------------------------------"
      puts ""
      puts "## Ingresses ##"
      puts ""
      puts get_all_ingresses(context)
      puts ""
      puts "## Services ##"
      puts ""
      display_all_service_data(context)
      puts ""
      puts ""
    end
  end

  def display_all_service_data(context)
    data = JSON.parse(get_all_services(context))

    # Heading
    puts "NAMESPACE                     WHITELISTED IPS"

    data["items"].each do |svc|
      if svc["spec"]["type"] == "LoadBalancer"
        namespace = "#{svc["metadata"]["namespace"]}"

        if svc["spec"]["loadBalancerSourceRanges"]?
          whitelisted_ips = svc["spec"]["loadBalancerSourceRanges"]
        else
          whitelisted_ips = "OPEN TO THE WORLD".colorize(:red)
        end

        spaces_to_subtract = namespace.to_s.size
        total_spaces = (30 - spaces_to_subtract)

        # Just makes it print nicely
        str = String.build do |str|
          str << "#{namespace}"
          total_spaces.times do
            str << " "
          end

          str << "#{whitelisted_ips}"
        end

        puts str
      end
    end
  end

  def get_all_ingresses(context)
    `kubectl get ing -o=wide --all-namespaces --context=#{context}`
  end

  def get_all_services(context)
    `kubectl get svc -o=json --all-namespaces --context=#{context}`
  end
end
