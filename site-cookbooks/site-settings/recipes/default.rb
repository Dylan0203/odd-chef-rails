#
# Cookbook Name:: site-settings
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
nginx_passenger_site "oddesign" do
  action :create
  dir    "/home/#{node[:user][:name]}/websites/oddesign"
  server "oddesign.expert"
end
