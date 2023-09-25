grammar LoxGrammar {

    token TOP {
        <declaration>*
    }

    #Statements
    rule statement {
        | <statement=expr-stmt>
        | <statement=for-stmt>
        | <statement=if-stmt>
        | <statement=print-stmt>
        | <statement=return-stmt>
        | <statement=while-stmt>
        | <statement=block>

    }

    rule for-stmt {
        'for' '('
        [
            | <var-decl>
            | <expr-stmt>
            | ';'
        ] <expression>? ';' <expression>? ')' <statement>
    }

    rule if-stmt {
        'if' '(' ~ ')' <expression> <statement>
    }

    rule print-stmt {
        'print' <expression> ';'
    }

    rule return-stmt {
        'return' <expression>? ';'
    }

    rule while-stmt {
        'while' '(' ~ ')' <expression> <statement>
    }

    rule expr-stmt {
        <expression> ';'
    }

    rule block {
        '{' ~ '}' <declaration>*
    }



    # Expressions
    rule expression {
        <assignment>
    }

    # There is ambiguity in the <call> rule itself and the rule call '.' <identifier>
    # since raku grammar does depth first search it will end up matching on the <call> rule only
    # and will never match on <call> '.' <identifier>
    # when it fails, it will travel through <logic-or> and match on the <call> rule.
    # To resolve this ambiguity problem we make this solution instead.
    token paren-dot-identifier {
        <paren-call>? <dot-op> <identifier>
    }

    rule assignment {
        | <identifier> <paren-dot-identifier>* <assignment-op> <assignment>
        | <logic-or>
    }

    rule logic-or {
        <logic-and>+ % <or-op>
    }

    rule logic-and {
        <equality>+ % <and-op>
    }

    rule equality {
        <comparison>+ % [
            | <not-equal-op>
            | <equal-op>
        ]
    }

    rule comparison {
        <term>+ % [
            | <greater-than-op>
            | <less-than-op>
            | <greater-than-equal-op>
            | <less-than-equal-op>
        ]
    }

    rule term {
        <factor>+ % [ <minus-op> | <plus-op> ]
    }

    rule factor  {
        <unary>+ % [ <division-op> | <multiplication-op> ]
    }

    rule unary {
        [<bang-op> | <minus-op>]* <call>
    }

    rule call {
        <primary> <call-tail>*
    }

    rule call-tail {
        <paren-call> | <dot-call>
    }

    rule paren-call {
        '(' ~ ')' <arguments>?
    }

    rule dot-call {
        '.' <identifier>
    }

    rule primary {
        | <boolean>
        | 'nil'
        | 'this'
        | <number>
        | <string>
        | <identifier>
        | '(' ~ ')' <expression>
        | 'super.' <identifier>
    }

    token boolean {
        'true' | 'false'
    }

    token string {
        '"' ~ '"' \w*
    }

    token identifier {
        [<:alpha> | '_'] \w*
    }

    token number {
        \d+ ['.' \d+]?
    }

    token division-op {
        '/'
    }

    token multiplication-op {
        '*'
    }

    token minus-op {
        '-'
    }

    token plus-op {
        '+'
    }

    token bang-op {
        '!'
    }

    token greater-than-op { '>' }
    token less-than-op { '<' }
    token less-than-equal-op { '<=' }
    token greater-than-equal-op { '>=' }
    token not-equal-op { '!=' }
    token equal-op { '==' }
    token and-op { 'and' }
    token or-op { 'or' }
    token assignment-op { '=' }
    token dot-op { '.' }
    # Expression END

    # Utility rules
    #
    rule function {
        <identifier> '(' ~ ')' <parameters>? <block>
    }

    rule parameters {
        <identifier> [',' <identifier>]*
    }

    rule arguments {
        <expression> [',' <expression>]*
    }

    #Declarations
    token declaration {
        | <declaration=class-decl>
        | <declaration=fun-decl>
        | <declaration=var-decl>
        | <declaration=statement>
    }

    rule class-decl {
        'class' <identifier> ['<' <identifier>]?
        '{' <function>* '}'
    }

    rule fun-decl {
        'fun' <function>
    }

    rule var-decl {
        'var' <identifier> ['=' <expression>]? ';'
    }



}
