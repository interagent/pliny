require "spec_helper"

describe Pliny::Log do
  before do
    @io = StringIO.new
    Pliny.stdout = @io
    Pliny.stderr = @io
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

  describe "scrubbing" do

    it "allows a Proc to be assigned as a log scrubber" do
      Pliny.log_scrubber = -> (hash) { hash }

      begin
        Pliny.log_scrubber = Object.new
        fail
      rescue ArgumentError; end
    end

    describe "when a scrubber is present" do
      before do
        Pliny.log_scrubber = -> (hash) {
          Hash.new.tap do |h|
            hash.keys.each do |k|
              h[k] = "*SCRUBBED*"
            end
          end
        }
      end

      after do
        Pliny.log_scrubber = nil
      end

      it "scrubs the log when a scrubber is present" do
        Pliny::RequestStore.store[:log_context] = { app: "pliny" }

        expect(@io).to receive(:print).with("app=*SCRUBBED* foo=*SCRUBBED*\n")

        Pliny.log(foo: "bar")
      end
    end
  end

  describe "unparsing" do
    it "removes nils from log" do
      expect(@io).to receive(:print).with("\n")

      Pliny.log(foo: nil)
    end

    it "leaves bare keys for true values" do
      expect(@io).to receive(:print).with("foo\n")

      Pliny.log(foo: true)
    end

    it "truncates floats" do
      expect(@io).to receive(:print).with("foo=3.142\n")

      Pliny.log(foo: Math::PI)
    end

    it "outputs times in ISO8601 format" do
      expect(@io).to receive(:print).with("foo=2020-01-01T00:00:00Z\n")

      Pliny.log(foo: Time.utc(2020))
    end

    it "quotes strings that contain spaces" do
      expect(@io).to receive(:print).with("foo=\"string with spaces\"\n")

      Pliny.log(foo: "string with spaces")
    end

    it "replaces newlines in strings" do
      expect(@io).to receive(:print).with("foo=\"string\\nwith newlines\\n\"\n")

      Pliny.log(foo: "string\nwith newlines\n")
    end

    it "by default interpolates objects into strings" do
      expect(@io).to receive(:print).with("foo=message\n")
      expect(@io).to receive(:print).with("foo=42\n")
      expect(@io).to receive(:print).with("foo=bar\n")

      Pliny.log(foo: StandardError.new("message"))
      Pliny.log(foo: 42)

      klass = Class.new do
        def to_s
          "bar"
        end
      end
      Pliny.log(foo: klass.new)
    end

    it "quotes strings that are generated from object interpolation" do
      expect(@io).to receive(:print).with("foo=\"message with space\"\n")
      expect(@io).to receive(:print).with("foo=\"bar with space\"\n")

      Pliny.log(foo: StandardError.new("message with space"))

      klass = Class.new do
        def to_s
          "bar with space"
        end
      end
      Pliny.log(foo: klass.new)
    end
  end
end
