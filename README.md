# Crystal - Chainable Methods

This is an attempt to replicate Chainable Methods as I have implemented for Ruby here:

    https://github.com/akitaonrails/chainable_methods

Crystal does not have runtime introspection and reflection as Ruby, so the only other way is to replicate some of the features at compile-time using macros to manipulate the AST.

The [original solution](https://carc.in/#/r/fg2) was proposed by @waterlink at a [discussion thread](https://github.com/crystal-lang/crystal/issues/1388) about the Pipe Operator in the Crystal repository.

This allows to make something like this:

    include CrChainableMethods::Pipe
    result = pipe "Hello World"
      .>> Foo.split_words
      .>> Foo.append_message("Bar")
      .>> Bar.add_something
      .>> Foo.join
      .>> unwrap

## Installation

You can add this library as a dependency in your `shard.yml` file.

## Usage

Right now you can include the Pipe module in the Program so the `pipe` macro is globally available.

## Development

The way it's built right now requires stringification of the AST to replace the ">>" pseudo-operator as the ".pipe" macro. But this means that any ">>" will be replaced, even if it's passed as a string argument in one of the chained methods, for example.

My original Ruby implementation takes care of chaining a method that the previous returned object knows how to respond, so instead of passing the returned object as the first argument of the method, it tries to call the method in the object itself. This is not covered in the implementation. For example:

    "Hello World"
      .>> split(",")

In the Ruby version the above becomes:

    "Hello World".split(",")

But in the current Crystal version this becomes:

    split("Hello World", ",")

And this will obviously fail unless you have another "split" function that satisfies the signature above.

Finally, if you chain methods from different modules, you need to explicitly use the "Module.method()" notation. And the way the AST is traversed requires a second stringification to remove the /\(.*\)$/ from this call to properly allow this format, this may lead to other side-effects in the process.

## Contributing

1. Fork it ( https://github.com/akitaonrails/cr_chainable_methods/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [AkitaOnrails](https://github.com/akitaonrails) - creator of this lib, maintainer
- [Oleksii Fedorov](https://github.com/waterlink) - creator of the original AST transformation algorithm

