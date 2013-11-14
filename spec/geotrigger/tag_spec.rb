require_relative './spec_helper'
require 'pry'
require 'pry-nav'

describe ArcGIS::Geotrigger::Tag do

  TAG_PERMS = 'deviceList',
          'deviceLocation',
          'deviceTagging',
          'deviceToken',
          'discoverable',
          'triggerApply',
          'triggerDelete',
          'triggerHistory',
          'triggerList',
          'triggerUpdate'

  let :session do
    ArcGIS::Geotrigger::Session.new client_id: CONF[:client_id],
                                    client_secret: CONF[:client_secret]
  end

  let :tag do
    ArcGIS::GT::Tag.create session, tags: "foo#{Time.now.to_i}"
  end

  let :dev do
    s = ArcGIS::GT::AGO::Session.new client_id: CONF[:client_id],
                                     type: :device

    # can't use this because GT doesn't know it yet
    #
    ago_did = s.device_data['deviceId']

    # make a call to GT so it learns of new device
    #
    at = s.access_token
    r = HTTPClient.new.get ArcGIS::Geotrigger::Session::BASE_URL % 'device/list',
                           nil,
                           'Authorization' => "Bearer #{at}"

    gt_did = JSON.parse(r.body)['devices'][0]['deviceId']

    # assert ids are the same
    #
    ago_did.should eq gt_did

    ArcGIS::GT::Device.new client_id: CONF[:client_id],
                           client_secret: CONF[:client_secret],
                           device_id: ago_did
  end

  let :trigger_opts do
    {
      'condition' => {
        'direction' => 'enter',
        'geo' => {
          'latitude' => 45.5165,
          'longitude' => -122.6764,
          'distance' => 100
        }
      },
      'action' => {
        'trackingProfile' => 'adaptive'
      }
    }
  end

  let :trigger do
    ArcGIS::GT::Trigger.create session, trigger_opts
  end

  it 'creates a tag' do
    t = tag
    t.name.should match /^foo/
    TAG_PERMS.each {|p| t.__send__(p).should_not be nil}
  end

  it 'fetches triggers' do
    t = tag
    trig = trigger
    trig.add_tags t.name
    trig.save
    t.triggers.first.data.should eq trig.data
  end

  it 'fetches devices' do
    t = tag
    d = dev
    d.add_tags t.name
    d.save
    t.devices.first.device_id.should eq d.device_id
  end

  it 'updates permissions' do
    t = tag
    t.name.should match /^foo/
    t_data = t.data.dup
    TAG_PERMS.each do |p|
      t.data[p] = !t_data[p]
      doid = t.data.object_id
      t.save
      t.data.object_id.should_not eq doid
      t.data[p].should eq !t_data[p]
    end
  end

end