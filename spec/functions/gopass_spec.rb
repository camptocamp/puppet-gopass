require 'spec_helper'

describe 'gopass' do
  it { is_expected.not_to eq(nil) }
  it {
    is_expected.to run \
      .with_params({}) \
      .and_raise_error(
        ArgumentError, \
        Regexp.new(Regexp.escape("'gopass' parameter 'key' expects a String value, got Hash")),
      )
  }

  context 'when secret does not exist' do
    it 'should return nil' do
      Puppet::Util::Execution.expects(:execute).with('gopass list --flat').returns("foo\nbar\nbaz\n")
      is_expected.to run.with_params('test').and_return(nil)
    end
  end

  context 'when secret has password and yaml body' do
    it 'should parse password, body and data' do
      Puppet::Util::Execution.expects(:execute).with('gopass list --flat').returns("foo\nbar\nbaz\n")
      Puppet::Util::Execution.expects(:execute).with("gopass 'foo'").returns("mypasswd\n---\nkey: val\nkey2: ['val10', 'val11']\n")

      is_expected.to run.with_params('foo').and_return({
        'password' => 'mypasswd',
        'body'     => "---\nkey: val\nkey2: ['val10', 'val11']",
        'data'     => {
          'key'  => 'val',
          'key2' => [ 'val10', 'val11'],
        },
      })
    end
  end

  context 'when secret has password only' do
    it 'should parse password, body and data' do
      Puppet::Util::Execution.expects(:execute).with('gopass list --flat').returns("foo\nbar\nbaz\n")
      Puppet::Util::Execution.expects(:execute).with("gopass 'foo'").returns("mypasswd\n")

      is_expected.to run.with_params('foo').and_return({
        'password' => 'mypasswd',
        'body'     => nil,
        'data'     => nil,
      })
    end
  end

  context 'when secret has password and blob body' do
    it 'should parse password, body and data' do
      Puppet::Util::Execution.expects(:execute).with('gopass list --flat').returns("foo\nbar\nbaz\n")
      Puppet::Util::Execution.expects(:execute).with("gopass 'foo'").returns("mypasswd\nthis is a \nrandom: unparsable body\n")

      is_expected.to run.with_params('foo').and_return({
        'password' => 'mypasswd',
        'body'     => "this is a \nrandom: unparsable body",
        'data'     => nil,
      })
    end
  end
end
