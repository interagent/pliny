require "spec_helper"
require "pliny/db_support"

describe Pliny::DbSupport do
  let(:support) { Pliny::DbSupport.new(ENV["DATABASE_URL"]) }

  before(:all) do
    @db = Sequel.connect(ENV["DATABASE_URL"])
    @path = "/tmp/pliny-test"
  end

  before(:each) do
    @db.tables.each { |t| @db.drop_table(t) }
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
      assert_equal [:foo, :schema_migrations], @db.tables.sort
      assert_equal [:bar, :id], @db[:foo].columns.sort
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

    it "reverts one migration" do
      support.migrate
      support.rollback
      assert_equal [:first, :schema_migrations, :second], @db.tables.sort
      support.rollback
      assert_equal [:first, :schema_migrations], @db.tables.sort
    end
  end
end
