require 'pliny/commands/generator'
require 'pliny/commands/generator/model'
require 'spec_helper'

describe Pliny::Commands::Generator::Model do
  subject { Pliny::Commands::Generator::Model.new(model_name, {}, StringIO.new) }

  around do |example|
    Dir.mktmpdir { |dir| Dir.chdir(dir, &example) }
  end

  before { Timecop.freeze(@t = Time.now) }

  after { Timecop.return }

  describe '#run' do
    before do
      subject.run
    end

    describe 'simple model' do
      let(:model_name) { 'artist' }

      it 'creates a migration' do
        assert File.exist?("db/migrate/#{@t.to_i}_create_artists.rb")
      end

      it 'creates the actual model' do
        assert File.exist?('lib/models/artist.rb')
      end

      it 'creates a test' do
        assert File.exist?('spec/models/artist_spec.rb')
      end
    end

    describe 'model in nested class' do
      let(:model_name) { 'administration/user' }

      it 'creates a migration' do
        assert File.exist?("db/migrate/#{@t.to_i}_create_administration_users.rb")
      end

      it 'creates the actual model' do
        assert File.exist?('lib/models/administration/user.rb')
      end

      it 'creates a test' do
        assert File.exist?('spec/models/administration/user_spec.rb')
      end
    end
  end
end
