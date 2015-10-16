require_relative "../test_helper"


class GcloudPubSubOutputTest < Test::Unit::TestCase
  DEFAULT_CONFIG = <<-EOC
    type gcloud_pubsub
    project project-test
    topic topic-test
    key key-test
    flush_interval 1
  EOC
  ReRaisedError = Class.new(RuntimeError)

  def setup
    Fluent::Test.setup
  end

  def create_driver(conf)
    Fluent::Test::BufferedOutputTestDriver.new(Fluent::GcloudPubSubOutput).configure(conf)
  end

  def test_configure
    d = create_driver(<<-EOC)
      type gcloud_pubsub
      project project-test
      topic topic-test
      key key-test
      flush_interval 1
    EOC

    assert_equal('project-test', d.instance.project)
    assert_equal('topic-test', d.instance.topic)
    assert_equal('key-test', d.instance.key)
    assert_equal(1, d.instance.flush_interval)
  end

  def test_re_raise_errors
    d = create_driver(DEFAULT_CONFIG)
    chunk = Fluent::MemoryBufferChunk.new('key', 'data')
    client = Object.new
    def client.publish
      raise ReRaisedError
    end
    d.instance.instance_variable_set(:@client, client)

    assert_raises ReRaisedError do
      d.instance.write(chunk)
    end
  end
end
