require_relative './spec_helper'
require 'pry'

describe ArcGIS::Geotrigger::Trigger do

  let :session do
    ArcGIS::Geotrigger::Session.new client_id: CONF[:client_id],
                                    client_secret: CONF[:client_secret]
  end

  let :opts do
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
    ArcGIS::GT::Trigger.create session, opts
  end

  it 'should create a trigger' do
    t = trigger
    t.trigger_id.should_not be nil
    t.condition.should eq opts['condition']
    t.action.should eq opts['action']
  end

  it 'fetches tags' do
    ts = trigger.tags
    ts.should_not be nil
    ts.should be_a Array
    ts.first.should be_a ArcGIS::GT::Tag
    ts.first.name.should eq trigger.default_tag
  end

  it 'knows the default tag' do
    trigger.default_tag =~ /^trigger:\S+$/
  end

  it 'updates' do
    trigger.properties = {'foo' => 'bar'}
    trigger.action['trackingProfile'] = 'adaptive'
    trigger.save
    trigger.properties.should eq({'foo' => 'bar'})
    trigger.action['trackingProfile'].should eq 'adaptive'
  end

  it 'adds tags' do
    ts = trigger.tags
    ts.length.should eq 1
    trigger.add_tags 'foo', 'bar'
    trigger.save
    ts = trigger.tags
    ts.length.should eq 3
  end

  it 'sets tags' do
    ts = trigger.tags
    ts.length.should eq 1
    trigger.tags = trigger.default_tag, 'fu', 'bat'
    trigger.save
    ts = trigger.tags
    ts.length.should eq 3
  end

  it 'removes tags' do
    trigger.tags = trigger.default_tag, 'fizz', 'buzz'
    trigger.save
    sleep 3
    ts = trigger.tags
    ts.length.should eq 3
    trigger.remove_tags 'fizz', 'buzz'
    trigger.save
    ts = trigger.tags
    ts.length.should eq 1
  end


end
