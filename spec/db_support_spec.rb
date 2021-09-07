require "spec_helper"
require "pliny/db_support"

describe Pliny::DbSupport do
  subject(:support) { Pliny::DbSupport.new(url, logger) }
  let(:url) { ENV["TEST_DATABASE_URL"] }
  let(:logger) { Logger.new(StringIO.new) }

  around do |example|
    Dir.mktmpdir("plinytest-") do |dir|
      Dir.chdir(dir) do
        FileUtils.mkdir_p("./db/migrate")

        example.run
      end
    end
  end

  before do
    DB.tables.each { |t| DB.drop_table(t) }
  end

  describe ".admin_url" do
    it "connects to the postgres system's db" do
      assert_equal "postgres://1.2.3.4/postgres",
        Pliny::DbSupport.admin_url("postgres://1.2.3.4/my-db")
    end
  end

  describe ".setup?" do
    it "checks if the database is responsive" do
      assert_equal true, Pliny::DbSupport.setup?(url)
      assert_equal false, Pliny::DbSupport.setup?("postgres://localhost/does-not-exist")
    end
  end

  describe "#migrate" do
    before do
      File.open("./db/migrate/#{Time.now.to_i}_create_foo.rb", "w") do |f|
        f.puts "
          Sequel.migration do
            change do
              create_table(:foo) do
                primary_key :id
                text        :bar
              end
            end
          end
        "
      end
    end

    it "migrates the database" do
      support.migrate
      assert_equal [:foo, :schema_migrations], DB.tables.sort
      assert_equal [:bar, :id], DB[:foo].columns.sort
    end
  end

  describe "#rollback" do
    before do
      @t = Time.now
      File.open("./db/migrate/#{(@t - 2).to_i}_first.rb", "w") do |f|
        f.puts "Sequel.migration { change { create_table(:first) } }"
      end

      File.open("./db/migrate/#{(@t - 1).to_i}_second.rb", "w") do |f|
        f.puts "Sequel.migration { change { create_table(:second) } }"
      end
    end

    it "reverts migrations" do
      support.migrate
      assert_equal [:first, :schema_migrations, :second], DB.tables.sort
      support.rollback
      assert_equal [:first, :schema_migrations], DB.tables.sort
      support.rollback
      assert_equal [:schema_migrations], DB.tables.sort
    end

    it "handle blank databases (no schema_migrations table)" do
      support.rollback # noop
    end

    it "handles databases not migrated (schema_migrations is empty)" do
      support.migrate((@t - 2).to_i)
      support.rollback # destroy table, leave schema_migrations
      support.rollback # should noop
    end
  end

  describe "#version" do
    it "is zero if the migrations table doesn't exist" do
      assert_equal 0, support.version
    end

    context "with migrations table" do
      before do
        DB.create_table(:schema_migrations) do
          text :filename
        end
      end

      it "is zero if the migrations table is empty" do
        assert_equal 0, support.version
      end

      it "is the highest timestamp from a filename in the migrations table" do
        migrations = DB[:schema_migrations]
        migrations.insert(filename: "1630551344_latest_change.rb")
        migrations.insert(filename: "1524000760_earlier_change.rb")

        assert_equal 1630551344, support.version
      end
    end
  end

  describe "MigrationStatus" do
    let(:filename) { "1630551344_latest_change.rb" }
    let(:migration_status) { described_class::MigrationStatus.new(filename: filename) }

    describe "#status" do
      context "given a migration present on disk" do
        before do
          migration_status.present_on_disk = true
        end

        context "and present in the database" do
          before do
            migration_status.present_in_database = true
          end

          it "is :up" do
            assert_equal :up, migration_status.status
          end
        end

        context "and is absent from the database" do
          before do
            migration_status.present_in_database = false
          end

          it "is :down" do
            assert_equal :down, migration_status.status
          end
        end
      end

      context "given a migration absent from disk" do
        before do
          migration_status.present_on_disk = false
        end

        context "and present in the database" do
          before do
            migration_status.present_in_database = true
          end

          it "is :file_missing" do
            assert_equal :file_missing, migration_status.status
          end
        end

        context "and is absent from the database" do
          before do
            migration_status.present_in_database = false
          end

          it "is an error case" do
            assert_raises RuntimeError do
              migration_status.status
            end
          end
        end
      end
    end
  end

  describe 'MigrationStatusPresenter' do
    let(:filename) { '1630551344_latest_change.rb' }
    let(:up_migration) { described_class::MigrationStatus.new(filename: "00#{filename}") }
    let(:down_migration) { described_class::MigrationStatus.new(filename: "0#{filename}") }
    let(:file_missing_migration) { described_class::MigrationStatus.new(filename: "000#{filename}") }
    let(:migration_statuses) { [up_migration, down_migration, file_missing_migration] }
    let(:presenter) { described_class::MigrationStatusPresenter.new(migration_statuses: migration_statuses) }

    before do
      up_migration.present_in_database = true
      up_migration.present_on_disk = true
      down_migration.present_in_database = false
      down_migration.present_on_disk = true
      file_missing_migration.present_in_database = true
      file_missing_migration.present_on_disk = false
    end

    describe '#barrier_row' do
      it 'pads to the longest_migration name' do
        expectation = '+--------------+--------------------------------+'
        assert_equal expectation, presenter.barrier_row
      end
    end

    describe '#header_row' do
      it 'pads to the longest migration name' do
        expectation = '|    STATUS    |           MIGRATION            |'
        assert_equal expectation, presenter.header_row
      end
    end

    describe '#header' do
      let(:barrier) { '+--------------+--------------------------------+' }
      let(:header)  { '|    STATUS    |           MIGRATION            |' }

      it 'wraps the title in barriers' do
        assert_equal [barrier, header, barrier], presenter.header
      end
    end

    describe '#footer' do
      let(:barrier) { '+--------------+--------------------------------+' }

      it 'just a barrier' do
        assert_equal [barrier], presenter.footer
      end
    end

    describe '#status_row' do
      context 'an up migration' do
        it 'shows the correct details' do
          expectation = '|      UP      | 001630551344_latest_change.rb  |'
          assert_equal expectation, presenter.status_row(up_migration)
        end
      end

      context 'a down migration' do
        it 'shows the correct details' do
          expectation = '|     DOWN     | 01630551344_latest_change.rb   |'
          assert_equal expectation, presenter.status_row(down_migration)
        end
      end

      context 'a file missing migration' do
        it 'shows the correct details' do
          expectation = '| FILE MISSING | 0001630551344_latest_change.rb |'
          assert_equal expectation, presenter.status_row(file_missing_migration)
        end
      end
    end

    describe '#statuses' do
      let(:up_expectation)           { '|      UP      | 001630551344_latest_change.rb  |' }
      let(:down_expectation)         { '|     DOWN     | 01630551344_latest_change.rb   |' }
      let(:file_missing_expectation) { '| FILE MISSING | 0001630551344_latest_change.rb |' }

      it 'returns strings' do
        assert_equal [up_expectation, down_expectation, file_missing_expectation], presenter.statuses
      end
    end

    describe '#rows' do
      let(:barrier)                  { '+--------------+--------------------------------+' }
      let(:header)                   { '|    STATUS    |           MIGRATION            |' }
      let(:up_expectation)           { '|      UP      | 001630551344_latest_change.rb  |' }
      let(:down_expectation)         { '|     DOWN     | 01630551344_latest_change.rb   |' }
      let(:file_missing_expectation) { '| FILE MISSING | 0001630551344_latest_change.rb |' }
      let(:footer)                   { '+--------------+--------------------------------+' }

      it 'is the table as an array' do
        expectation = [
          barrier,
          header,
          barrier,
          up_expectation,
          down_expectation,
          file_missing_expectation,
          footer
        ]

        assert_equal expectation, presenter.rows
      end
    end

    describe '#to_s' do
      it 'is the table as a string' do
        expectation = <<~OUTPUT.chomp
          +--------------+--------------------------------+
          |    STATUS    |           MIGRATION            |
          +--------------+--------------------------------+
          |      UP      | 001630551344_latest_change.rb  |
          |     DOWN     | 01630551344_latest_change.rb   |
          | FILE MISSING | 0001630551344_latest_change.rb |
          +--------------+--------------------------------+
        OUTPUT

        assert_equal expectation, presenter.to_s
      end
    end
  end

  describe '#status' do
    let(:filename) { '1630551344_latest_change.rb' }
    let(:up_migration) { "00#{filename}" }
    let(:down_migration) { "0#{filename}" }
    let(:file_missing_migration) { "000#{filename}" }

    before do
      DB.create_table(:schema_migrations) do
        text :filename
      end

      migrations = DB[:schema_migrations]
      migrations.insert(filename: up_migration)
      migrations.insert(filename: file_missing_migration)

      File.open("./db/migrate/#{up_migration}", "w") do |f|
        f.puts "
          Sequel.migration do
            change do
              create_table(:foo) do
                primary_key :id
                text        :bar
              end
            end
          end
        "
      end

      File.open("./db/migrate/#{down_migration}", "w") do |f|
        f.puts "
          Sequel.migration do
            change do
              create_table(:foo) do
                primary_key :id
                text        :bar
              end
            end
          end
        "
      end
    end

    it 'returns a table string' do
      expectation = <<~OUTPUT.chomp
        +--------------+--------------------------------+
        |    STATUS    |           MIGRATION            |
        +--------------+--------------------------------+
        | FILE MISSING | 0001630551344_latest_change.rb |
        |      UP      | 001630551344_latest_change.rb  |
        |     DOWN     | 01630551344_latest_change.rb   |
        +--------------+--------------------------------+
      OUTPUT

      assert_equal expectation, support.status
    end
  end
end
