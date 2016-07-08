require "./cr_chainable_methods/*"

# this was copied from https://carc.in/#/r/fg2
# thanks to @waterlink from this issue thread https://github.com/crystal-lang/crystal/issues/1388

module CrChainableMethods
  module Pipe
    macro pipe(ast)
      # This is the way to have a pseudo-operator, the problem is that the gsub will replace the
      # >> string everywhere including if it's part of a method argument

      # example: "\"Hello World\" >> (Foo.split_words >> ((Foo.append_message(\"Bar\")) >> (Bar.add_something >> (Foo.join >> unwrap))))"
      {% uast = ast.stringify.gsub(/ >>/, ".pipe").id %}
      # becomes: "\"Hello World\".pipe (Foo.split_words.pipe ((Foo.append_message(\"Bar\")).pipe (Bar.add_something.pipe (Foo.join.pipe unwrap))))"

      {% if uast.stringify != ast.stringify %}
        pipe {{uast}}

      {% else %}
        {% if ast.name.id == "pipe".id %}
          {% first_arg = ast.args.first.args.argify %}

          {% if ast.args.first.receiver.is_a?(Nop) %}
            {{ast.args.first.name}}({{ast.receiver}}, {{ast.args.first.args.argify}})

          {% else %}
            {% receiver_name = ast.args.first.receiver.stringify.gsub(/\(.*\)$/, "").id %}
            {% receiver_args = ast.args.first.receiver.args.argify %}

            {% if receiver_name.stringify.split(".").size > 1 %}
              pipe {{receiver_name}}({{ast.receiver}}, {{receiver_args}}).pipe {{first_arg}}
            {% else %}
              pipe {{ast.receiver}}.{{receiver_name}}({{receiver_args}}).pipe {{first_arg}}
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
