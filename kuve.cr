require "./namespaces.cr"
require "./restarts.cr"
require "./nodes.cr"
require "./db-con.cr"
require "./open.cr"
require "./exec.cr"
require "./exposed.cr"
require "./crashed.cr"
require "./top.cr"
require "./secrets.cr"
require "./crashed_logs.cr"
require "colorize"
require "json"

# Have a command for a namespace
# Have a command for a project (eg kubectl get pods --all-namespaces)
# kubectl get events --namespace=balh

begin
  File.open("/usr/local/bin/kuve_conf.json")
rescue
  puts "Missing kuve_conf.json please see kuve_conf.sample"
  exit(1)
end

# Grab the context set it as global variable
if ARGV.size > 1 && ARGV[-2] == "-c"
  context = ARGV[-1]
else
  context = "default"
end

def print_logo
  logo = AnimatedLogo.new
  sleep 1
  logo.stop
end

def print_kuve_context
  puts ""

  print_logo

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
    puts " * #{key} -> #{value}"
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
  print_logo

  puts ""
  puts "$ kuve -h                           shows this message"
  puts "$ kuve logs crashed <namespace>     shows the previous container logs if container has crashed"
  puts "$ kuve crashed [-c]                 shows all pods in a project that are not running"
  puts "$ kuve top <pods> || <nodes> [-c]   shows kubectl top for pods or nodes"
  puts "$ kuve exposed [-c]                 shows all externally faceing endpoints"
  puts "$ kuve <namespace> [-c]             shows all pods in a namespace for each project"
  puts "$ kuve restarts [-c]                shows top six pod restarts in namespace and node"
  puts "$ kuve restarts -a [-c]             shows all pod restarts in namespace and node"
  puts "$ kuve nodes [-c]                   shows all warning and error messages for all nodes in a project"
  puts "$ kuve secrets <namespace>          shows secrets for a given namespace, decrypted from base64"
  puts "$ kuve db-con <project> <namespace> connects you to the cloud-sql-proxy for that namespace's db"
  puts "$ kuve exec <namespace>             provides string to exec into pod"
  puts "$ kuve o <project keyword>          opens the project specified by kuve.conf in your web browser"
  puts "$ kuve conf                         view your configuration shortcuts"
  puts ""
  puts "[-c] optional flag to indicate context group which is set in kuve_conf.json, defaults to default context group"
  puts "$ kuve restarts -a -c my-context-group"
  puts "will show you all restarts over all contexts within that context group"
  puts ""
elsif ARGV[0] == "conf"
  print_kuve_context
elsif ARGV[0] == "logs"
  if ARGV[1] == "crashed" || ARGV[1] == "-c"
    if ARGV[2]
      c = CrashedLogs.new(ARGV[2])
      c.get_logs
    else
      puts "Please specify a namespace"
    end
  elsif ARGV[1] != "crashed" || ARGV[1] != "-c"
    puts "Unknown subcommand"
  else
    puts "Please specify a sub command"
  end
elsif ARGV[0] == "top"
  if ARGV[1] == "nodes" || ARGV[1] == "node" || ARGV[1] == "-n"
    t = Top.new(context, "node")
    t.run_top
  elsif ARGV[1] == "pods" || ARGV[1] == "pod" || ARGV[1] == "-p"
    t = Top.new(context, "pod")
    t.run_top
  else
    puts "You need to specify nodes or pods"
  end
elsif ARGV[0] == "crashed"
  c = Crashed.new(context)
  c.get_all_crashed_pods
elsif ARGV[0] == "nodes"
  no = Nodes.new(context)
  no.get_all_nodes
elsif ARGV[0] == "exposed"
  e = Exposed.new(context)
  e.get_all_exposed
elsif ARGV[0] == "secrets"
  if ARGV.size == 2
    s = Secrets.new(ARGV[1])
    s.decode_secrets(s.grab_secrets)
  else
    puts "You need to specify a namespace"
  end
elsif ARGV[0] == "exec"
  if ARGV.size == 3
    e = Exec.new(ARGV[1], ARGV[2])
    e.exec_into_pod
  elsif ARGV.size == 2
    e = Exec.new(ARGV[1], "false")
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
elsif ARGV[0] == "-o" || ARGV[0] == "open" || ARGV[0] == "o"
  o = Open.new(ARGV[1])
  o.open
else
  na = Namespace.new(context)
  na.get_all_pods_all_namespaces_all_envs
end
