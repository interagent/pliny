require 'test_helper'

describe Pliny::Commands::Generator do
  before do
    @gen = Pliny::Commands::Generator.new({}, {}, StringIO.new)
  end

  describe '#run!' do
    before do
      FileUtils.mkdir_p('/tmp/plinytest')
      Dir.chdir('/tmp/plinytest')
      Timecop.freeze(@t = Time.now)
    end

    after do
      FileUtils.rmdir('/tmp/plinytest')
      Timecop.return
    end

    describe 'generating endpoints' do
      before do
        @gen.args = %w(endpoint artists)
        @gen.run!
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

    describe 'generating mediators' do
      before do
        @gen.args = ['mediator', 'artists/creator']
        @gen.run!
      end

      it 'creates a new mediator module' do
        assert File.exist?('lib/mediators/artists/creator.rb')
      end

      it 'creates a test' do
        assert File.exist?('spec/mediators/artists/creator_spec.rb')
      end
    end

    describe 'generating models' do
      describe 'simple model' do
        before do
          @gen.args = %w(model artist)
          @gen.run!
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
          @gen.args = ['model', 'administration/user']
          @gen.run!
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

    describe 'generating scaffolds' do
      before do
        @gen.args = %w(scaffold artist)
        @gen.run!
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
        assert File.exist?('docs/schema/schemata/artist.yaml')
      end

      it 'creates a new serializer module' do
        assert File.exist?('lib/serializers/artist.rb')
      end

      it 'creates a test' do
        assert File.exist?('spec/serializers/artist_spec.rb')
      end
    end

    describe 'generating schemas' do
      before do
        @gen.args = %w(schema artist)
        @gen.run!
      end

      it 'creates a schema' do
        assert File.exist?('docs/schema/schemata/artist.yaml')
      end
    end

    describe 'generating serializers' do
      before do
        @gen.args = %w(serializer artist)
        @gen.run!
      end

      it 'creates a new serializer module' do
        assert File.exist?('lib/serializers/artist.rb')
      end

      it 'creates a test' do
        assert File.exist?('spec/serializers/artist_spec.rb')
      end
    end
  end
end
