require 'shellwords'
require_relative '../lib/execute.rb'

Given(/^I have pulled the image ([^\s]+)$/) do |image_name|
  @image_name = image_name
  @escaped_image_name = Shellwords.escape(image_name)
  execute("docker-compose pull #{@escaped_image_name}")
end

When(/^I start a container based on the image$/) do
  @docker_compose_exit_code = execute("docker-compose run --rm #{@escaped_image_name}")
end

Then(/^the container should start successfully$/) do
  expect(@docker_compose_exit_code).to eq(0)
end
