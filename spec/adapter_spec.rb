# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

require_relative 'spec_helper'

describe 'vcloud_router_creator_microservice' do
  before do
    allow_any_instance_of(Object).to receive(:sleep)
    require_relative '../adapter'
  end

  describe '#delete_router' do
    let!(:data) do
      { router_type:     'vcloud',
        datacenter_name: 'r3-acidre',
        datacenter_username: 'acidre@r3labs-development',
        datacenter_password: 'test',
        client_name:     'r3labs-development',
        vse_url:         'https://vse-creator-service.ernest.io',
        name:     'test' }
    end

    describe 'when remote server is not available' do
      it 'should call vse-creator api' do
        VCR.use_cassette(:remote_not_available) do
          expect(delete_router(data)).to eq 'router.delete.vcloud.done'
        end
      end
    end

    describe 'when router is successfully created' do
      it 'should call vse-creator api' do
        VCR.use_cassette(:successfully_created) do
          expect(delete_router(data)).to eq 'router.delete.vcloud.done'
        end
      end
    end
    
  end
end
