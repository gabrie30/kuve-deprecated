# vim: set ts=2 sw=2 noet fileencoding=utf-8:

require "./fancy.cr"
require "colorize"

class Namespace
  class NamespacePodInformation
    getter :ctx, :data

    def initialize(@ctx : String, @data : String)
    end
  end

  def initialize(context : String)
    @context = context
    @data = Array(String).new
  end

  def contexts
    JSON.parse(File.open("/usr/local/bin/kuve_conf.json"))["rawcontexts"][@context].map { |value| value.to_s }
  end

  def get_deployed_image(context)
    deployment_json = `kubectl get deployment -o=json #{namespace} --context=#{context}`
    deployment = JSON.parse(deployment_json)

    begin
      deployment["items"].first["spec"]["template"]["spec"]["containers"].first["image"]
    rescue
      ""
    end
  end

  def get_events(context)
    deployment_json = `kubectl get events -o=json #{namespace} --context=#{context}`

    deployment = JSON.parse(deployment_json)

    str = String.build do |str|
      deployment["items"].each do |item|
        if item["type"] == "Warning" || item["type"] == "Error"
          str << "!!!!!!!!  #{item["type"]} EVENT !!!!!!!!\n".colorize(:red)
          str << "Count: #{item["count"]}\n"
          str << "Message: #{item["message"]}\n"
          str << "Source: #{item["source"]["component"]}\n"
          str << "\n"
        end
      end
    end

    str
  end

  def get_all_pods_all_namespaces_all_envs
    channel = Channel(NamespacePodInformation).new

    progress = ProgressIndicator.new("Querying nodes...")
    contexts.each do |ctx|
      spawn do
        str = String.build do |str|
          image_info = (get_deployed_image ctx).to_s

          if !image_info.empty?
            sha = image_info.to_s.split(":").last
            @data << sha

            str << ("%*s%*s\n\n" % [60 + image_info.size / 2, image_info, 60 - image_info.size / 2, ""]).gsub(" ", "-")

            output = IO::Memory.new
            Process.run "kubectl",
              ["get", "pods", "-o", "wide", "#{namespace}", "--context", ctx], output: output
            output.close
            str << output.to_s

            event_info = get_events ctx
            if !event_info.empty?
              str << "\n\n"
              str << event_info
            end

            str << "\n\n"
          end
        end

        # send the results async to the receiver below
        channel.send NamespacePodInformation.new ctx, str
      end
    end

    # as each sub-task completes, collect its results and bucket by context
    results = Hash(String, String).new
    contexts.each do
      result = channel.receive
      results[result.ctx] = result.data
    end

    progress.stop

    # output the results by context, in order
    contexts.each do |ctx|
      printf results[ctx]
    end

    puts @data
  end

  def namespace
    "--namespace=#{ARGV[0]}"
  end
end
