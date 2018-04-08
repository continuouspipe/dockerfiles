require 'pp'
require 'yaml'

config = YAML.safe_load(File.read('docker-compose.yml'))

config['services'].reject! do |service_name, _service|
  service_name =~ /^external_/
end
services = config['services'].map do |service_name, service|
  [
    service_name,
    if service.key? 'depends_on'
      service['depends_on'].reject { |dependency| dependency =~ /^external_/ }
    else
      []
    end
  ]
end.to_h

def expand_dependencies(services, service_name)
  dependencies = []
  services[service_name].each do |dependency_name|
    dependencies += [dependency_name]
    dependencies += expand_dependencies(services, dependency_name)
  end
  dependencies
end

services.each_key do |service_name|
  services[service_name] = expand_dependencies(services, service_name).uniq
end

services.each do |service_name, dependencies|
  print "    | #{service_name} | #{dependencies.join(',')} |\n"
end
