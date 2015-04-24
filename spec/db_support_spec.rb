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
end
