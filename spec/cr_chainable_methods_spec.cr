require "./spec_helper"
include CrChainableMethods::Pipe

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

describe CrChainableMethods do
  it "should chain Module's methods calls" do
    result = pipe ["Hello", "World"]
      .>> Foo.append_message("Foo")
      .>> Bar.add_something
      .>> unwrap

    ["Hello", "World", "Foo", "something"].should eq(result)
  end

  it "should chain the object methods directly, so it's similar to just doing the dot notation" do
    result = pipe "Hello World Foo Bar"
      .>> downcase
      .>> split
      .>> reverse
      .>> join(" - ")
      .>> unwrap

    "Hello World Foo Bar"
      .downcase
      .split
      .reverse
      .join(" - ")
      .should eq(result)
  end

  it "should chain Procs together" do
    result = pipe "Hello World Foo Bar"
      .>> ->(s : String) { s.downcase }.call
      .>> ->(s : String) { s.split }.call
      .>> ->(a : Array(String)) { a.reverse }.call
      .>> ->(a : Array(String)) { a.join(" - ")}.call
      .>> unwrap

    "Hello World Foo Bar"
      .downcase
      .split
      .reverse
      .join(" - ")
      .should eq(result)
  end

  it "should chain methods from external modules, methods from the resulting object, and Procs all together" do
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
