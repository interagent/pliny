require "spec_helper"

describe Pliny::Log do
  before do
    @io = StringIO.new
    Pliny.stdout = @io
    Pliny.stderr = @io
    allow(@io).to receive(:print)
  end

  after do
    Pliny.default_context = {}
  end

  it "logs in structured format" do
    expect(@io).to receive(:print).with("foo=bar baz=42\n")
    Pliny.log(foo: "bar", baz: 42)
  end

  it "re-raises errors" do
    assert_raises(RuntimeError) do
      Pliny.log(foo: "bar") do
        raise RuntimeError
      end
    end
  end

  it "supports blocks to log stages and elapsed" do
    expect(@io).to receive(:print).with("foo=bar at=start\n")
    expect(@io).to receive(:print).with("foo=bar at=finish elapsed=0.000\n")
    Pliny.log(foo: "bar") do
    end
  end

  it "merges default context" do
    Pliny.default_context = { app: "pliny" }
    expect(@io).to receive(:print).with("app=pliny foo=bar\n")
    Pliny.log(foo: "bar")
  end

  it "logs with just default context" do
    Pliny.default_context = { app: "pliny" }
    Pliny::RequestStore.store[:log_context] = { request_store: true }
    expect(@io).to receive(:print).with("app=pliny foo=bar\n")
    Pliny.log_with_default_context(foo: "bar")
  end

  it "logs without context" do
    Pliny.default_context = { app: "pliny" }
    expect(@io).to receive(:print).with("foo=bar\n")
    Pliny.log_without_context(foo: "bar")
  end

  it "merges context from RequestStore" do
    Pliny::RequestStore.store[:log_context] = { app: "pliny" }
    expect(@io).to receive(:print).with("app=pliny foo=bar\n")
    Pliny.log(foo: "bar")
  end

  it "supports a context" do
    expect(@io).to receive(:print).with("app=pliny foo=bar\n")
    Pliny.context(app: "pliny") do
      Pliny.log(foo: "bar")
    end
  end

  it "local context does not overwrite default context" do
    Pliny.default_context = { app: "pliny" }
    expect(@io).to receive(:print).with("app=not_pliny foo=bar\n")
    Pliny.log(app: 'not_pliny', foo: "bar")
    assert Pliny.default_context[:app] == "pliny"
  end

  it "local context does not overwrite request context" do
    Pliny::RequestStore.store[:log_context] = { app: "pliny" }
    expect(@io).to receive(:print).with("app=not_pliny foo=bar\n")
    Pliny.context(app: "not_pliny") do
      Pliny.log(foo: "bar")
    end
    assert Pliny::RequestStore.store[:log_context][:app] == "pliny"
  end

  it "local context does not propagate outside" do
    Pliny::RequestStore.store[:log_context] = { app: "pliny" }
    expect(@io).to receive(:print).with("app=pliny foo=bar\n")
    Pliny.context(app: "not_pliny", test: 123) do
    end
    Pliny.log(foo: "bar")
  end

  it "logs exceptions" do
    Pliny::RequestStore.store[:log_context] = { app: "pliny" }
    e = RuntimeError.new
    expect(@io).to receive(:print).with("app=pliny exception class=RuntimeError message=RuntimeError exception_id=#{e.object_id}\n")
    Pliny.log_exception(e)
  end
end
