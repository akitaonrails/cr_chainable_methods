# Crystal - Chainable Methods

This is an attempt to replicate Chainable Methods as I have implemented for Ruby here:

    https://github.com/akitaonrails/chainable_methods

Crystal does not have runtime introspection and reflection as Ruby, so the only other way is to replicate some of the features at compile-time using macros to manipulate the AST.

The [original solution](https://carc.in/#/r/fg2) was proposed by @waterlink at a [discussion thread](https://github.com/crystal-lang/crystal/issues/1388) about the Pipe Operator in the Crystal repository.

This allows to make something like this:

    include CrChainableMethods::Pipe
    result = pipe "Hello World"
      .>> split(" ")
      .>> Foo.append_message("from module")
      .>> Bar.add_something
      .>> ->(l : Array(String)){ l + ["from block"] }.call
      .>> join(" - ")
      .>> unwrap

## Installation

You can add this library as a dependency in your `shard.yml` file.

## Usage

Right now you can include the Pipe module in the Program so the `pipe` macro is globally available.

With this new pseudo-operator ".>>" you can chain together:

  * methods from the resulting object itself (like calling #split for "Hello World")
  * passing the resulting object as the first argument of module function (such as Bar.add_something)
  * passing the resulting object as the argument for a Proc call (you have to specify the type)

And at this point it must always end with the #unwrap call to get the final result.

## Development

The way it's built right now requires stringification of the AST to replace the ">>" pseudo-operator as the ".pipe" macro. But this means that any ">>" will be replaced, even if it's passed as a string argument in one of the chained methods, for example.

If you chain methods from different modules, you need to explicitly use the "Module.method()" notation. And the way the AST is traversed requires a second stringification to remove the /\(.*\)$/ from this call to properly allow this format, this may lead to other side-effects in the process.

## Contributing

1. Fork it ( https://github.com/akitaonrails/cr_chainable_methods/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [AkitaOnrails](https://github.com/akitaonrails) - creator of this lib, maintainer
- [Oleksii Fedorov](https://github.com/waterlink) - creator of the original AST transformation algorithm

