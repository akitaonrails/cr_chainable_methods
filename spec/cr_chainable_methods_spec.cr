require "./spec_helper"

module Foo
  def self.append_message(words, message)
    words + [message]
  end
end

module Bar
  def self.add_something(words)
    words + ["something"]
  end
end

include CrChainableMethods::Pipe

describe CrChainableMethods do
  it "should chain methods from the module, using the result of the previous as the first argument for the next" do
    result = pipe "Hello World"
      .>> split(" ")
      .>> Foo.append_message("from module")
      .>> Bar.add_something
      .>> ->(l : Array(String)){ l + ["from block"] }.call
      .>> join(" - ")
      .>> unwrap

    "Hello - World - from module - something - from block".should eq(result)
  end
end
