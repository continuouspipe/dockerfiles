require 'yaml'

config = YAML.safe_load(File.read('docker-compose.yml'))

config['services'].reject! do |service_name, _service|
  service_name =~ /^(external_|nginx_ingress_controller|.*php55.*)/
end

config['services'].each do |_, service|
  service.select! do |key, _|
    key == 'image'
  end
  service['image'].sub!(':latest', ':stable') if service.key? 'image'
  service['build'] = '/dev/null' if service.key? 'image'
end

config['services'].reject! do |_, service|
  service == {}
end

new_keys = config['services'].keys.map do |service_name|
  service_name + '_stable'
end
config['services'] = new_keys.zip(config['services'].values).to_h

File.write('docker-compose.stable.yml', YAML.dump(config))
