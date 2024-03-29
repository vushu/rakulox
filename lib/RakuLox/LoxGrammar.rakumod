use RakuLox::ErrorReport;
grammar LoxGrammar does FailGoalErrorReport does HighWaterErrorReport {

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
        'for' '(' [ 
            | <initializer=var-decl>
            | <initializer=expr-stmt>
            | <semicolon>] 
        <expression>? ';' <expression>? ')' <statement>
    }

    token semicolon {
        ';'
    }

    rule if-stmt {
        'if' '(' ~ ')' <expression> <statement> <else-branch>?
    }

    rule else-branch {
        'else' <statement>
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

    rule assignment {
        [<call> '.']? <logic-or>+ % <assignment-op>
    }

    rule logic-or {
        <logic-and>+ % <or-op>
    }

    rule logic-and {
        <equality>+ % <and-op>
    }

    rule equality {
        <comparison>+ % <equality-op>
    }

    token equality-op {
        | <not-equal-op>
        | <equal-op>
    }

    rule comparison {
        <term>+ % <comparison-op>
    }

    token comparison-op {
        | <greater-than-op>
        | <less-than-op>
        | <greater-than-equal-op>
        | <less-than-equal-op>
    }

    rule term {
        <factor>+ % <term-op>
    }

    token term-op {
        | <minus-op>
        | <plus-op>
    }

    rule factor  {
        <unary>+ % <factor-op>
    }

    token factor-op {
        | <division-op>
        | <multiplication-op>
    }

    rule unary {
        <unary-op> <unary> | <call>
    }

    token unary-op {
        | <bang-op>
        | <minus-op>
    }

    token right-paren {
        ')'
    }

    token left-paren {
        '('
    }

    rule call {
        <primary> [<left-paren><arguments>?<right-paren> | '.' <identifier>]*
    }

    rule primary {
        | <boolean>
        | <nil>
        | <this>
        | <number>
        | <string>
        | <identifier>
        | <group-expression>
        | <super-class>
    }

    token nil {
        'nil'
    }

    token this {
        'this'
    }

    rule group-expression {
        '(' ~ ')' <expression>
    }

    rule super-class {
        'super.' <identifier>
    }

    token boolean {
        'true' | 'false'
    }

    token string {
        '"' <(.*?)> '"'
    }

    token identifier {
        [<:alpha> | '_'] [<:alpha> | '_' | \d]*
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
        'var' <identifier> [<assignment-op> <expression>]? ';'
    }

    method error($msg) {
        my $parsed = self.target.substr(0, self.pos)\
        .trim-trailing;
        my $context = $parsed.substr($parsed.chars - 10 max 0) ~ ' 👈' ~ self.target.substr($parsed.chars, 10);
        my $line-no = $parsed.lines.elems;
        my $error-msg = "Oh 💩 I cannot parse: $msg\nat line $line-no, around:" ~ $context;
        die $error-msg;
    }
}
