class DBCon
  def initialize(proj : String, namespace : String)
    @project = proj
    @namespace = namespace
  end

  def proxy
    service_account_directory = JSON.parse(File.open("/usr/local/bin/kuve_conf.json"))["db-con"]["service_account_directory"]
    apps_directory = JSON.parse(File.open("/usr/local/bin/kuve_conf.json"))["db-con"]["apps_directory"]

    # Does not currently support more than one region
    # Your kuve_conf.json setting for this can be dynamic
    # eg: db_conn_string: "#{@project}:us-region:#{@namespace}"
    db_con_string = JSON.parse(File.open("/usr/local/bin/kuve_conf.json"))["db-con"]["db_conn_string"]

    app_decrypt = "#{apps_directory}/#{@namespace}/config/deploy/#{@project}/secrets.ejson"
    full_service_account_directory = "#{service_account_directory}/#{@project}.json"

    system("ejson decrypt #{app_decrypt}")
    system("echo")
    system("echo make sure you use port 15432 to connect!")
    system("echo psql -U USER_NAME -h 127.0.0.1 -p 15432 DB_NAME")
    system("echo")
    system("echo make sure you use port 15432 to connect!")
    system("cloud_sql_proxy -credential_file #{full_service_account_directory} -instances=#{db_conn_string}=tcp:127.0.0.1:15432")
  end
end
