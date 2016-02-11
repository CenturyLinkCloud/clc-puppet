require 'spec_helper'
require 'puppet_x/century_link/config'
require 'hocon/config_factory'

def nil_environment_variables
  ENV.delete('CLC_USERNAME')
  ENV.delete('CLC_PASSWORD')
end

def create_config_file(path, config)
  file_contents = %{
clc: {
  username: #{config[:username]}
  password: #{config[:password]}
}
  }
  File.open(path, 'w') { |f| f.write(file_contents) }
end

def create_incomplete_config_file(path, config)
  file_contents = %{
clc: {
  username: #{config[:username]}
}
  }
  File.open(path, 'w') { |f| f.write(file_contents) }
end


describe PuppetX::CenturyLink::Config do
  let(:config_file_path) { File.join(Dir.pwd, '.puppet_clc.conf') }

  context 'with the relevant environment variables set' do
    let(:config) { described_class.new }

    before(:all) do
      @config = {
        username: 'john',
        password: 'passw0rd',
      }
      nil_environment_variables
      ENV['CLC_USERNAME'] = @config[:username]
      ENV['CLC_PASSWORD'] = @config[:password]
    end

    it 'should allow for calling default_config_file more than once' do
      config.default_config_file
      expect { config.default_config_file }.not_to raise_error
    end

    [:username, :password].each do |field|
      it "should return the #{field} from an ENV variable" do
        expect(config.send(field)).to eq(@config[field])
      end
    end

    it 'should set the default config file location to confdir' do
      expect(File.dirname(config.default_config_file)).to eq(Puppet[:confdir])
    end
  end

  context 'with no environment variables and a valid config file' do
    let(:config) { described_class.new(config_file_path) }

    before(:all) do
      @config = {
        username: 'john',
        password: 'passw0rd',
      }
      @path = File.join(Dir.pwd, '.puppet_clc.conf')
      create_config_file(@path, @config)
      nil_environment_variables
    end

    after(:all) { File.delete(@path) }

    [:username, :password].each do |field|
      it "should return the #{field} from the config file" do
        expect(config.send(field)).to eq(@config[field])
      end
    end
  end

  context 'with no environment variables or config file' do
    before(:all) do
      nil_environment_variables
    end

    it 'should raise a suitable error' do
      expect {
        described_class.new
      }.to raise_error(Puppet::Error, /You must provide credentials in either environment variables or a config file/)
    end
  end

  context 'with incomplete configuration in environment variables' do
    before(:all) do
      ENV['CLC_USERNAME'] = 'abcv123'
      ENV['CLC_PASSWORD'] = nil
    end

    it 'should raise an error about the missing variables' do
      expect {
        described_class.new
      }.to raise_error(Puppet::Error, /To use this module you must provide the following settings: password/)
    end
  end

  context 'with no environment variables and an incomplete config file' do
    before(:all) do
      @config = {
        username: 'john',
      }
      @path = File.join(Dir.pwd, '.puppet_clc.conf')
      create_incomplete_config_file(@path, @config)
      nil_environment_variables
    end

    after(:all) { File.delete(@path) }

    it 'should raise an error about the missing variables' do
      expect {
        described_class.new(@path)
      }.to raise_error(Puppet::Error, /To use this module you must provide the following settings: password/)
    end
  end
end
