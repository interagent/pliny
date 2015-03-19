require "spec_helper"

describe Pliny::Log do
  before do
    @io = StringIO.new
    Pliny.stdout = @io
    stub(@io).print
  end

  after do
    Pliny.default_context = { }
  end

  it "logs in structured format" do
    mock(@io).print "foo=bar baz=42\n"
    Pliny.log(foo: "bar", baz: 42)
  end

  it "supports blocks to log stages and elapsed" do
    mock(@io).print "foo=bar at=start\n"
    mock(@io).print "foo=bar at=finish elapsed=0.000\n"
    Pliny.log(foo: "bar") do
    end
  end

  it "merges default context" do
    Pliny.default_context = { app: "pliny" }
    mock(@io).print "app=pliny foo=bar\n"
    Pliny.log(foo: "bar")
  end

  it "merges context from RequestStore" do
    Pliny::RequestStore.store[:log_context] = { app: "pliny" }
    mock(@io).print "app=pliny foo=bar\n"
    Pliny.log(foo: "bar")
  end

  it "supports a context" do
    mock(@io).print "app=pliny foo=bar\n"
    Pliny.context(app: "pliny") do
      Pliny.log(foo: "bar")
    end
  end

  it "local context does not overwrite default context" do
    Pliny.default_context = { app: "pliny" }
    mock(@io).print "app=not_pliny foo=bar\n"
    Pliny.log(app: 'not_pliny', foo: "bar")
    assert Pliny.default_context[:app] = "pliny"
  end

  it "local context does not overwrite request context" do
    Pliny::RequestStore.store[:log_context] = { app: "pliny" }
    mock(@io).print "app=not_pliny foo=bar\n"
    Pliny.context(app: "not_pliny") do
      Pliny.log(foo: "bar")
    end
    assert Pliny::RequestStore.store[:log_context][:app] = "pliny"
  end

  it "local context does not propagate outside" do
    Pliny::RequestStore.store[:log_context] = { app: "pliny" }
    mock(@io).print "app=pliny foo=bar\n"
    Pliny.context(app: "not_pliny", test: 123) do
    end
    Pliny.log(foo: "bar")
  end
end
