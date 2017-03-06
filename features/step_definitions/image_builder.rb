require 'shellwords'
require_relative '../lib/execute.rb'

Given(/^the image ([^\s]+) has dependencies ([^\s]*)\s*$/) do |image_name, image_dependencies|
  @image_name = image_name
  @escaped_image_name = Shellwords.escape(image_name)
  @image_dependencies = image_dependencies.split(',')
  @escaped_image_dependencies = @image_dependencies.map { |dependency| Shellwords.escape(dependency) }
end

Given(/^I have built the image ([^\s]+)$/) do |image_name|
  @image_name = image_name
  @escaped_image_name = Shellwords.escape(image_name)
end

When(/^I build the image and it's dependencies$/) do
  @docker_compose_exit_code = execute("docker-compose build #{@escaped_image_dependencies.join(" ")} #{@escaped_image_name}")
end

Then(/^the build should complete successfully$/) do
  expect(@docker_compose_exit_code).to eq(0)
end
