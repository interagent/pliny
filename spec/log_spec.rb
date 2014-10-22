require "spec_helper"

describe Pliny::Log do
  before do
    @io = StringIO.new
    Pliny.stdout = @io
    stub(@io).puts
  end

  it "logs in structured format" do
    mock(@io).puts "foo=bar baz=42"
    Pliny.log(foo: "bar", baz: 42)
  end

  it "supports blocks to log stages and elapsed" do
    mock(@io).puts "foo=bar at=start"
    mock(@io).puts "foo=bar at=finish elapsed=0.000"
    Pliny.log(foo: "bar") do
    end
  end

  it "merges context from RequestStore" do
    Pliny::RequestStore.store[:log_context] = { app: "pliny" }
    mock(@io).puts "app=pliny foo=bar"
    Pliny.log(foo: "bar")
  end

  it "supports a context" do
    mock(@io).puts "app=pliny foo=bar"
    Pliny.context(app: "pliny") do
      Pliny.log(foo: "bar")
    end
  end

  it "local context does not overwrite global" do
    Pliny::RequestStore.store[:log_context] = { app: "pliny" }
    mock(@io).puts "app=not_pliny foo=bar"
    Pliny.context(app: "not_pliny") do
      Pliny.log(foo: "bar")
    end
    assert Pliny::RequestStore.store[:log_context][:app] = "pliny"
  end

  it "local context does not propagate outside" do
    Pliny::RequestStore.store[:log_context] = { app: "pliny" }
    mock(@io).puts "app=pliny foo=bar"
    Pliny.context(app: "not_pliny", test: 123) do
    end
    Pliny.log(foo: "bar")
  end
end
