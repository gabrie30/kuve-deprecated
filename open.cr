# Kuve open will first look for a project name specified in the kuve_conf.json
# If it does not see the project it will assume you want to open the github repo from the org specified

class Open
  def initialize(project : String)
    @project = project
  end

  def urls
    JSON.parse(File.open("/usr/local/bin/kuve_conf.json"))["open"]
  end

  # Todo figure out a way to handle errors with this
  def open
    if urls[(@project)]?
      system("open #{urls[(@project)]}")
    elsif urls["github_org"] != "github-org-to-open-repos-from"
      system("open https://github.com/#{urls["github_org"]}/#{@project}")
    else
      puts "Error: You have not configured this feature properly. Please update your kuve_conf.json then run `$ make update` to resolve"
    end
  end
end
