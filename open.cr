class Open
  def initialize(project : String)
    @project = project
  end

  def urls
    JSON.parse(File.open("/usr/local/bin/kuve_conf.json"))["open"]
  end

  def open
    if urls[(@project)]?
      system("open #{urls[(@project)]}")
    else
      puts "Error: You have not configured this feature properly. Please update your kuve_conf.json then run `$ make update` to resolve"
    end
  end
end
