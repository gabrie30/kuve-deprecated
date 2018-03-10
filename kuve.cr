require "./namespaces.cr"
require "./restarts.cr"
require "./nodes.cr"
require "./db-con.cr"
require "./open.cr"
require "./exec.cr"
require "colorize"
require "json"

# Have a command for a namespace
# Have a command for a project (eg kubectl get pods --all-namespaces)
# kubectl get events --namespace=balh

# Grab the context set it as global variable
if ARGV.size > 1 && ARGV[-2] == "-c"
  context = ARGV[-1]
else
  context = "default"
end

def print_kuve_context
  conf = JSON.parse(File.open("/usr/local/bin/kuve_conf.json"))
  puts ""
  puts "-- Additonal Context Groups --"
  conf["rawcontexts"].each do |key, value|
    next if key == "default"
    puts " * #{key}"
  end

  puts ""

  puts "-- Open Shortcuts --"
  conf["open"].each do |key, value|
    puts " * #{key}"
  end

  puts ""
end

if ARGV.size == 0 || ARGV[0] == "-h" || ARGV[0] == "h" || ARGV[0] == "--help"
  # puts ""
  # puts "*****************************************************************".colorize.yellow
  # puts ""
  # puts "      :::    :::      :::    :::    :::     :::       ::::::::::".colorize.light_yellow
  # puts "     :+:   :+:       :+:    :+:    :+:     :+:       :+:        ".colorize.light_yellow
  # puts "    +:+  +:+        +:+    +:+    +:+     +:+       +:+         ".colorize.light_yellow
  # puts "   +#++:++         +#+    +:+    +#+     +:+       +#++:++#     ".colorize.yellow
  # puts "  +#+  +#+        +#+    +#+     +#+   +#+        +#+           ".colorize.yellow
  # puts " #+#   #+#       #+#    #+#      #+#+#+#         #+#            ".colorize.light_yellow
  # puts "###    ###       ########         ###           ##########      ".colorize.light_yellow
  # puts ""
  # puts "*****************************************************************".colorize.yellow
  logo = AnimatedLogo.new
  sleep 1
  logo.stop

  puts ""
  puts "$ kuve -h                           shows this message"
  puts "$ kuve <namespace>                  shows all pods in a namespace for each project"
  puts "$ kuve restarts                     shows top six pod restarts in namespace and node"
  puts "$ kuve restarts -a                  shows all pod restarts in namespace and node"
  puts "$ kuve nodes                        shows all warning and error messages for all nodes in a project"
  puts "$ kuve db-con <project> <namespace> connects you to the cloud-sql-proxy for that namespace's db"
  puts "$ kuve exec <namespace>             provides string to exec into pod"
  puts "$ kuve o <project keyword>          opens the project specified by kuve.conf in your web browser"
  puts "$ kuve conf                         view your configuration shortcuts"
  puts ""
  puts "Note: To use other context groups use -c at the end of your command eg;"
  puts "$ kuve restarts -a -c my-context-group"
  puts ""
elsif ARGV[0] == "conf"
  print_kuve_context
elsif ARGV[0] == "nodes"
  no = Nodes.new(context)
  no.get_all_nodes
elsif ARGV[0] == "exec"
  if ARGV[1]
    e = Exec.new(ARGV[1])
    e.exec_into_pod
  else
    puts "You need to specify a namespace"
  end
elsif ARGV[0] == "db-con"
  if ARGV[1] && ARGV[2]
    d = DBCon.new(ARGV[1], ARGV[2])
    d.proxy
  else
    puts "Needs to be like $ kuve db-con <project> <namespace>"
  end
elsif ARGV[0] == "restarts"
  a = Restarts.new(context)
  if (ARGV.size > 1) && (ARGV[1] == "-a" || ARGV[1] == "a")
    a.show_all_restarts("all")
  else
    a.show_all_restarts("top")
  end
elsif ARGV[0] == "o"
  o = Open.new(ARGV[1])
  o.open
else
  na = Namespace.new(context)
  na.get_all_pods_all_namespaces_all_envs
end
