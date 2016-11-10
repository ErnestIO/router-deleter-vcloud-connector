# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require 'rubygems'
require 'bundler/setup'

require 'nats/client'
require 'net/http'
require 'net/https'
require 'json'

def delete_router(data)
  vse_delete_router(data)
  'router.delete.vcloud.done'
rescue StandardError => e
  puts e
  data['error'] = { code: 0, message: e.to_s }
  'router.delete.vcloud.done' # May need to return a proper status code from the vse
end

def vse_delete_router(data)
  url = URI.parse("#{data[:vse_url]}/#{path}")
  req = prepare_request(url, data)
  https_request(url, req)
end

def prepare_request(url, data)
  credentials = data[:datacenter_username].split('@')
  req = Net::HTTP::Delete.new(url.path)
  req.basic_auth data[:datacenter_username], data[:datacenter_password]
  req.body = { 'vdc-name'     => data[:datacenter_name],
               'org-name'     => credentials.last,
               'router-name'  => data[:name] }.to_json
  req
end

def https_request(url, req)
  http = Net::HTTP.new(url.host, url.port)
  http.read_timeout = 720
  http.use_ssl = true
  res = http.start { |h| h.request(req) }
  raise res.message if res.code != '200'
  res.body
end

def path
  'router'
end

unless defined? @@test
  loop do
    begin
      NATS.start(servers: [ENV['NATS_URI']]) do
        NATS.subscribe 'router.delete.vcloud' do |msg, _rply, sub|
          @data = { id: SecureRandom.uuid, type: sub }
          @data.merge! JSON.parse(msg, symbolize_names: true)

          @data[:type] = delete_router(@data)
          NATS.publish(@data[:type], @data.to_json)
        end
      end
    rescue NATS::ConnectError
      puts "Error connecting to nats on #{ENV['NATS_URI']}, retrying in 5 seconds.."
      sleep 5
    end
  end
end
