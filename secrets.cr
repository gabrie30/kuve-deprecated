class Secrets
    def initialize(namespace : String)
        @namespace = namespace
    end

    def grab_secrets
        all_secrets = `kubectl get secrets -n #{@namespace}`
        system("kubectl get secrets -n #{@namespace}")
        puts "Which secret from the above list do you wish to view? Please type in a value below and hit enter."
        begin
            secret_to_view = STDIN.gets
            if secret_to_view == ""
                puts "You didn't enter a secret name, aborting process."
                Process.exit
            end
        rescue
            puts "Something horrible happened."
        end
        return secret_to_view
    end

    def decode_secrets(grab_secrets)
        begin
            b64_secrets = JSON.parse(`kubectl get secret #{grab_secrets} -o json -n #{@namespace}`)
            b64_secrets["data"].each do |key,value|
                # logic to base64 decode each value
                decrypted = `echo #{value} | base64 -D`
                puts "#{key}: #{decrypted}"
            end
        rescue
            puts "Could Not parse secrets, please ensure you entered a valid namespace or secret name for the namespace."
        end
    end
end