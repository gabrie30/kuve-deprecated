class DBCon
  def initialize(proj : String, namespace : String)
    @project = proj
    @namespace = namespace
  end

  def proxy
    service_account_directory = JSON.parse(File.open("/usr/local/bin/kuve_conf.json"))["db-con"]["service_account_directory"]
    apps_directory = JSON.parse(File.open("/usr/local/bin/kuve_conf.json"))["db-con"]["apps_directory"]

    # limited support for now
    db_con_string = "#{@project}:us-central1:#{@namespace}01"

    # TODO: needs to be pulled out to env var
    app_decrypt = "#{apps_directory}/#{@namespace}/#{@project}/secrets.ejson"
    full_service_account_directory = "#{service_account_directory}/#{@project}.json"

    system("ejson decrypt #{app_decrypt}")
    system("echo")
    system("echo make sure you use port 15432 to connect!")
    system("echo psql -U USER_NAME -h 127.0.0.1 -p 15432 DB_NAME")
    system("echo")
    system("echo make sure you use port 15432 to connect!")
    system("cloud_sql_proxy -credential_file #{full_service_account_directory} -instances=#{db_con_string}=tcp:127.0.0.1:15432")
  end
end
