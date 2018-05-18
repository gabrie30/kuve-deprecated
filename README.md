```
*****************************************************************

      :::    :::      :::    :::    :::     :::       ::::::::::
     :+:   :+:       :+:    :+:    :+:     :+:       :+:
    +:+  +:+        +:+    +:+    +:+     +:+       +:+
   +#++:++         +#+    +:+    +#+     +:+       +#++:++#
  +#+  +#+        +#+    +#+     +#+   +#+        +#+
 #+#   #+#       #+#    #+#      #+#+#+#         #+#
###    ###       ########         ###           ##########

*****************************************************************
```

Easily view important debugging information over multiple Kubernetes clusters.

# Installation

- $ brew update
- $ brew install crystal-lang
- $ git clone
- $ cd kuve
- $ cp kuve_conf.sample kuve_conf.json
- $ Update your kuve_conf.json (see Steps to get db-con working)
- $ make update

## Available commands

```
$ kuve -h                           help menu
$ kuve crashed [-c]                 shows all pods in a project that are not running
$ kuve top <pods> || <nodes> [-c]   shows kubectl top for pods or nodes
$ kuve exposed [-c]                 shows all externally facing endpoints
$ kuve <namespace> [-c]             shows all pods in a namespace for each project
$ kuve restarts -a [-c]             shows all pod restarts in namespace and node
$ kuve nodes [-c]                   shows all warning and error messages for all nodes in a project
$ kuve db-con <project> <namespace> connects you to the cloud-sql-proxy for that namespace's db
$ kuve exec <namespace>             exec into first running container of first pod found
$ kuve open <project/github>        opens a project in browser if specified by kuve.conf or defaults to github repo
$ kuve conf                         view your configuration shortcuts

[-c] optional flag to indicate context group which is set in kuve_conf.json, defaults to default context group

$ kuve restarts -a -c my-context-group
will show you all restarts over all contexts within that context group
```

## Steps to get db-con working

- You will need to have all your apps in one directory (see Apps Directory)
- You will need to add a directory with all psql-service-accounts.json - this is needed to connect to the proxy
- Update the kuve_conf.json to include these two paths
- If the db-con fails to run correctly, check that you have the repo cloned to the apps directory and that you have the service account for the project in the right directory
- Database region is limited to us-west1 (TODO Fix)

## Context groups

- You can setup multiple context groupings in your kuve_conf.json. This allows you to iterate over groupings of kubernetes contexts

## Apps directory

- kuve requires an apps_directory set in kuve_conf.json for db_con functionality. If you don't have one directory that holds all your orgs repos you can use a tool like ghorg to make it for you. <https://github.com/gabrie30/ghorg>

## Todo

- Better Error Messages
- More Functionality (Ideas/PR's Welcome)

## Developing locally

- $ crystal kuve.cr your-commands
