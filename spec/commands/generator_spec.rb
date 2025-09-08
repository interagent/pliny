# frozen_string_literal: true

require 'pliny/commands/creator'
require 'pliny/commands/generator'
require 'pliny/commands/generator/base'
require 'spec_helper'

describe Pliny::Commands::Generator do
  subject { Pliny::Commands::Generator.new }

  before do
    Timecop.freeze(@t = Time.now)

    allow_any_instance_of(Pliny::Commands::Generator::Base).to receive(:display)
  end

  around do |example|
    Dir.mktmpdir do |dir|
      app_dir = File.join(dir, "app")
      # some generators depend on files seeded by the template
      Pliny::Commands::Creator.run([app_dir], {}, StringIO.new)
      Dir.chdir(app_dir, &example)
    end
  end

  after do
    Timecop.return
  end

  describe '#endpoint' do
    before do
      subject.endpoint('artists')
    end

    it 'creates a new endpoint module' do
      assert File.exist?('lib/endpoints/artists.rb')
    end

    it 'creates an endpoint test' do
      assert File.exist?('spec/endpoints/artists_spec.rb')
    end

    it 'creates an endpoint acceptance test' do
      assert File.exist?('spec/acceptance/artists_spec.rb')
    end
  end

  describe '#mediator' do
    before do
      subject.mediator('artists/creator')
    end

    it 'creates a new mediator module' do
      assert File.exist?('lib/mediators/artists/creator.rb')
    end

    it 'creates a test' do
      assert File.exist?('spec/mediators/artists/creator_spec.rb')
    end
  end

  describe '#model' do
    describe 'simple model' do
      before do
        subject.model('artist')
      end

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
      before do
        subject.model('administration/user')
      end

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

  describe '#scaffold' do
    before do
      subject.scaffold('artist')
    end

    it 'creates a new endpoint module' do
      assert File.exist?('lib/endpoints/artists.rb')
    end

    it 'creates an endpoint test' do
      assert File.exist?('spec/endpoints/artists_spec.rb')
    end

    it 'creates an endpoint acceptance test' do
      assert File.exist?('spec/acceptance/artists_spec.rb')
    end

    it 'creates a migration' do
      assert File.exist?("db/migrate/#{@t.to_i}_create_artists.rb")
    end

    it 'creates the actual model' do
      assert File.exist?('lib/models/artist.rb')
    end

    it 'creates a test' do
      assert File.exist?('spec/models/artist_spec.rb')
    end

    it 'creates a schema' do
      assert File.exist?('schema/schemata/artist.yaml')
    end

    it 'creates a new serializer module' do
      assert File.exist?('lib/serializers/artist.rb')
    end

    it 'creates a test' do
      assert File.exist?('spec/serializers/artist_spec.rb')
    end
  end

  describe '#schema' do
    before do
      subject.schema('artist')
    end

    it 'creates a schema' do
      assert File.exist?('schema/schemata/artist.yaml')
    end
  end

  describe '#serializer' do
    before do
      subject.serializer('artist')
    end

    it 'creates a new serializer module' do
      assert File.exist?('lib/serializers/artist.rb')
    end

    it 'creates a test' do
      assert File.exist?('spec/serializers/artist_spec.rb')
    end
  end
end
