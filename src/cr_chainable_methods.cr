require "./cr_chainable_methods/*"

# this was copied from https://carc.in/#/r/fg2
# thanks to @waterlink from this issue thread https://github.com/crystal-lang/crystal/issues/1388

module CrChainableMethods
  module Pipe
    # This is the way to have a pseudo-operator, the problem is that the gsub will replace the
    # >> string everywhere including if it's part of a method argument
    #
    # The recursive #pipe call will transform the ast like this:
    #
    #    "\"Hello World Foo Bar\" >> (downcase >> (split >> (reverse >> ((join(\" - \")) >> unwrap))))"
    #    "\"Hello World Foo Bar\".pipe (downcase.pipe (split.pipe (reverse.pipe ((join(\" - \")).pipe unwrap))))"
    #    "\"Hello World Foo Bar\".pipe(downcase.pipe(split.pipe(reverse.pipe((join(\" - \")).pipe(unwrap)))))"
    #    "\"Hello World Foo Bar\".downcase.pipe(split.pipe(reverse.pipe((join(\" - \")).pipe(unwrap))))"
    #    "\"Hello World Foo Bar\".downcase.split.pipe(reverse.pipe((join(\" - \")).pipe(unwrap)))"
    #    "\"Hello World Foo Bar\".downcase.split.reverse.pipe((join(\" - \")).pipe(unwrap))"
    #    "(\"Hello World Foo Bar\".downcase.split.reverse.join(\" - \")).pipe(unwrap)"
    macro pipe(ast)
      {% uast = ast.stringify.gsub(/ >>/, ".pipe").id %}

      {% if uast.stringify != ast.stringify %}
        pipe {{uast}}

      {% else %}
        {% if ast.name.id == "pipe".id %}
          {% first_arg = ast.args.first.args.splat %}

          {% if ast.args.first.receiver.is_a?(Nop) %}
            {% if ast.args.first.args.size > 0 %}
              {{ast.args.first.name}}({{ast.receiver}}, {{ast.args.first.args.argify}})
            {% else %}
              {{ast.args.first.name}}({{ast.receiver}})
            {% end %}

          {% else %}
            {% receiver_method = ast.args.first.receiver.stringify.gsub(/\(.*\)$/, "").id %}
            {% receiver_args = ast.args.first.receiver.args.splat %}

            {% if receiver_method.stringify.split(".").size > 1 %}
              # if it is a `Module.method()` call pass the receiver as the first argument
              {% if receiver_args.size > 0 %}
                pipe {{receiver_method}}({{ast.receiver}}, {{receiver_args}}).pipe {{first_arg}}
              {% else %}
                pipe {{receiver_method}}({{ast.receiver}}).pipe {{first_arg}}
              {% end %}
            {% else %}
              # if the method can be called in the receiver itself, use dot-notation like `receiver.receiver_method`
              pipe {{ast.receiver}}.{{receiver_method}}({{receiver_args}}).pipe {{first_arg}}
            {% end %}
          {% end %}

        {% else %}
          {{ast}}
        {% end %}
      {% end %}
    end

    macro included
      #FIXME this should be used as the last call in the chain if the previous call explicitly calls from a module such as:
      # `.>> Foo.method .>> unwrap`
      # Still don't know why the ast parsing works ok for just `.>> method` but fails for `.>> Foo.method`
      def self.unwrap(foo)
        foo
      end
    end
  end
end
