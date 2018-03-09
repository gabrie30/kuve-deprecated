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

Easily view important debugging information over multiple environments.

# Installation

- $ brew update
- $ brew install crystal-lang
- $ cd kuve
- $ cp kuve_conf.sample kuve_conf.json
- $ Update your kuve_conf.json (see Steps to get db-con working)
- $ make update

## Available commands

```
$ kuve -h                           shows this message
$ kuve <namespace>                  shows all pods in a namespace for each project
$ kuve restarts                     shows top six pod restarts in namespace and node
$ kuve restarts -a                  shows all pod restarts in namespace and node
$ kuve nodes                        shows all warning and error messages for all nodes in a project
$ kuve db-con <project> <namespace> connects you to the cloud-sql-proxy for that namespace's db
$ kuve exec <namespace>             provides string to exec into pod
$ kuve o <project keyword>          opens the project specified by kuve.conf in your web browser

Note: To use other contexts groups use -c at the end of your command eg;
$ kuve restarts -a -c my-context-group
```


## Steps to get db-con working

- You will need to have all your apps in one directory
- You will need to add a directory with all psql-service-accounts.json - this is needed to connect to the proxy
- Update the kuve_conf.json to include these two paths
- If the db-con fails to run correctly, check that you have the repo cloned to the apps directory and that you have the service account for the project in the right directory
- Database region is limited to us-west1 (TODO Fix)

## Context groups

- You can setup multiple context groupings in your kuve_conf.json. This allows you to iterate over groupings of kubernetes contexts

## Todo

- Better Error Messages
- More Functionality (Ideas/PR's Welcome)

## Developing locally

- $ crystal kuve.cr your-commands
