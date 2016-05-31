require "./spec_helper"

module Foo
  def self.split_words(phrase)
    phrase.split(" ")
  end

  def self.append_message(words, message)
    words + [message]
  end

  def self.join(words)
    words.join(" - ")
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
      .>> Foo.split_words
      .>> Foo.append_message("Bar")
      .>> Bar.add_something
      .>> Foo.join
      .>> unwrap

    "Hello - World - Bar - something".should eq(result)
  end
end
