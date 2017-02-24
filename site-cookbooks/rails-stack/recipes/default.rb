#
# Cookbook Name:: rails-stack
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# install necessary package
%w{build-essential curl zlib1g-dev libreadline-dev libyaml-dev libxml2-dev libxslt-dev sqlite3 libsqlite3-dev make gcc ncurses-dev libgdbm-dev libffi-dev tk-dev python-software-properties libcurl4-openssl-dev libxslt1-dev libssl-dev imagemagick}.each do |pkg|
  package pkg do
    action :install
  end
end

# git コマンド
# action sync は初回時は clone, 存在していたら pull をする
git "/home/#{node[:user][:name]}/.rbenv" do
  repository "git://github.com/sstephenson/rbenv.git"
  reference "master"
  action :sync
  user "#{node[:user][:name]}"
  group "admin"
end

# directory コマンドでディレクトリ作成
["/home/#{node[:user][:name]}/.rbenv/plugins"].each do |dir|
  directory dir do
    action :create
    user "#{node[:user][:name]}"
    group "admin"
  end
end

git "/home/#{node[:user][:name]}/.rbenv/plugins/ruby-build" do
  repository "git://github.com/sstephenson/ruby-build.git"
  reference "master"
  action :sync
  user "#{node[:user][:name]}"
  group "admin"
end

git "/home/#{node[:user][:name]}/.rbenv/plugins/rbenv-gem-rehash" do
  repository "git://github.com/sstephenson/rbenv-gem-rehash.git"
  reference "master"
  action :sync
  user "#{node[:user][:name]}"
  group "admin"
end

# bash コマンドが使えるが複数回繰り返すと冪等性が保証されない
# 処理の中で、source ~/.zshrc をしているが再読込されないため
# 以降の処理を実行するには、一度 deployer から出て、再度 ssh ログインする必要がある
bash "insert_line_rbenvpath" do
  environment "HOME" => "/home/#{node[:user][:name]}"
  code <<-EOS
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc
    echo 'eval "$(rbenv init -)"' >> ~/.zshrc
    echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.zshrc
    source ~/.zshrc
    sudo chown -R #{node[:user][:name]}:admin ~/.rbenv
  EOS
end


bash "install ruby" do
  user "#{node[:user][:name]}"
  group "admin"
  environment "HOME" => "/home/#{node[:user][:name]}"
  code <<-EOS
    RUBY_CONFIGURE_OPTS=--with-readline-dir=`brew --prefix readline` /home/#{node[:user][:name]}/.rbenv/bin/rbenv install 2.3.3
    /home/#{node[:user][:name]}/.rbenv/bin/rbenv global 2.3.3
  EOS
end

bash "install rails" do
  user "#{node[:user][:name]}"
  group "admin"
  environment "HOME" => "/home/#{node[:user][:name]}"
  code <<-EOC
    export PATH="/home/#{node[:user][:name]}/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
    echo 'gem: --no-document' >> ~/.gemrc
    gem install rails
    gem install bundler
    /home/#{node[:user][:name]}/.rbenv/bin/rbenv rehash
  EOC
end


# install nodejs and npm
%w{nodejs npm}.each do |pkg|
  package pkg do
    action :install
  end
end

# install bower
bash 'install bower' do
  user "#{node[:user][:name]}"
  group "admin"
  environment "HOME" => "/home/#{node[:user][:name]}"
  code <<-EOS
    sudo npm install bower -g
  EOS
end

%w{mysql-server mysql-client libmysqlclient-dev postgresql postgresql-contrib libpq-dev}.each do |pkg|
  package pkg do
    action :install
  end
end
