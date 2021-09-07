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
end
