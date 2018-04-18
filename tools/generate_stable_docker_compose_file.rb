require 'yaml'

config = YAML.safe_load(File.read('docker-compose.yml'))

config['services'].reject! do |service_name, _service|
  service_name =~ /^external_/
end

config['services'].each do |_, service|
  service.select! do |key, _|
    key == 'image'
  end
  service['image'].sub!(':latest', ':stable') if service.key? 'image'
end

config['services'].reject! do |_, service|
  service == {}
end

File.write('docker-compose.stable.yml', YAML.dump(config))
