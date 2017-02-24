#
# Cookbook Name:: create-user
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package 'zsh' do
  action :install
end

group 'admin'

user node[:user][:name] do
  password node[:user][:password]
  gid "admin"
  home "/home/#{node[:user][:name]}"
  shell "/usr/bin/zsh"
  supports manage_home: true
end

ssh_authorize_key 'funnyq@FunnyQs-MacBook-Pro.local' do
  key 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDRuAsP0m5ALP8VnruwSeOUVJMkI/BbvpYunKhQ1N+pfihZtlz2lFQ4NjbqOorr9YsF1ENY6XnP3qIk7ftZSZSB86kDsv5YxJBpEm+hpHJiQ7/RAlG+XkkjnH0FuzX7kPEZowyud7EqL8C4eHKUJJQMAy4Dd92zsUMAqd32SqYVZ3BCLTb5Rs7xcaJ4elfYbUe5ZtTDu4WrXELpLlAze+uyeMQJ6GhiMkWOQrNCgg2bbGxQijZeEaVotG540IIrt9mjyKN8YCKAfRML4cfZHa3DZaZWjqYcHerA7n0udA64jEJrVgy/lJrvCzTdX6w4c3YAD4UfzfJAoRVbj3NGOZFb'
  user 'deployer'
end

bash 'install oh-my-zsh' do
  code <<-EOS
    wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh
  EOS
  user "#{node[:user][:name]}"
  group "admin"
  environment "HOME" => "/home/#{node[:user][:name]}"
end
