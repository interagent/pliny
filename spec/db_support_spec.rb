require "spec_helper"
require "pliny/db_support"

describe Pliny::DbSupport do
  let(:support) { Pliny::DbSupport.new(ENV["TEST_DATABASE_URL"]) }

  before(:all) do
    @path = "/tmp/pliny-test"
  end

  before(:each) do
    DB.tables.each { |t| DB.drop_table(t) }
    FileUtils.rm_rf(@path)
    FileUtils.mkdir_p("#{@path}/db/migrate")
    Dir.chdir(@path)
  end

  describe "#migrate" do
    before do
      File.open("#{@path}/db/migrate/#{Time.now.to_i}_create_foo.rb", "w") do |f|
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
      t = Time.now
      File.open("#{@path}/db/migrate/#{(t-3).to_i}_first.rb", "w") do |f|
        f.puts "Sequel.migration { change { create_table(:first) } }"
      end

      File.open("#{@path}/db/migrate/#{(t-2).to_i}_second.rb", "w") do |f|
        f.puts "Sequel.migration { change { create_table(:second) } }"
      end

      File.open("#{@path}/db/migrate/#{(t-1).to_i}_third.rb", "w") do |f|
        f.puts "Sequel.migration { change { create_table(:third) } }"
      end
    end

    it "reverts migrations" do
      support.migrate
      assert_equal [:first, :schema_migrations, :second, :third], DB.tables.sort
      support.rollback
      assert_equal [:first, :schema_migrations, :second], DB.tables.sort
      support.rollback
      assert_equal [:first, :schema_migrations], DB.tables.sort
      support.rollback
      assert_equal [:schema_migrations], DB.tables.sort
    end

    it "handle empty databases" do
      support.rollback # noop
    end
  end
end
