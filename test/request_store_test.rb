require "test_helper"

describe Pliny::RequestStore do
  before do
    @env = {
      "REQUEST_IDS" => ["abc", "def"]
    }
  end

  it "seeds :request_id" do
    Pliny::RequestStore.seed(@env)
    assert_equal "abc,def", Pliny::RequestStore.store[:request_id]
  end

  it "seeds :log_context" do
    Pliny::RequestStore.seed(@env)
    assert_equal "abc,def", Pliny::RequestStore.store[:log_context][:request_id]
  end

  it "is cleared by clear!" do
    Pliny::RequestStore.seed(@env)
    Pliny::RequestStore.clear!
    assert_nil Pliny::RequestStore.store[:request_id]
  end
end
