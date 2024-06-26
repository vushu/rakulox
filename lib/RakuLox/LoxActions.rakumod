use RakuLox::LoxAST;
class LoxActions {

    method TOP($/) {
        my @statements;
        for $<declaration> -> $decl {
            @statements.push($decl.made);
        }
        make @statements;
    }

    method declaration($/) {
        make $<declaration>.made;
    }

    method block($/) {
        make Block.new(statements => $<declaration>.map: *.made);
    }

    method statement($/){
        make $<statement>.made;
    }

    method class-decl ($/) {
        make ClassDeclaration.new(identifier => ($<identifier>[0].made).name);
    }

    method identifier ($/) {
        make Variable.new(name => ~$/);
    }

    method while-stmt($/) {
        make While.new(condition => $<expression>.made, body => $<statement>.made);
    }
    
    method for-stmt($/) {

        my $body = $<statement>.made;
        # handle increment
        if $<expression>[1] { # Increment
            my $block = Block.new;
            $block.statements.push($body);
            $block.statements.push(Expression.new(expression => $<expression>[1].made));
            $body = $block;
        }

        # handle condition
        my $condition;
        if not $<expression>[0] { # if no conditions
            $condition = Literal.new(True);
        }
        else {
            $condition = $<expression>[0].made;
        }

        $body = While.new(condition => $condition, body => $body);

        # handle initializer
        if $<initializer> {
            my $block = Block.new;
            $block.statements.push($<initializer>.made);
            $block.statements.push($body);
            $body = $block;
        }
        make $body;
    }

    method print-stmt($/) {
        make Print.new(expression => $<expression>.made);
    }

    method expr-stmt($/) {
        make Expression.new(expression => $<expression>.made);
    }

    method expression($/) {
        make $<assignment>.made;
    }

    multi method assignment($/ where $<assignment-op>) {
        make Assign.new(name=> ($<logic-or>[0].made).name, value=> $<logic-or>[1].made);
    }

    multi method assignment($/ where !$<assignment-op>) {
        make $<logic-or>[0].made;
    }

    multi method logic-or($/) {
        make make-logical-node($<logic-and>, $<or-op>);
    }

    multi method logic-and($/) {
        make make-logical-node($<equality>, $<and-op>);
    }

    multi method equality($/){
        make make-node($<comparison>, $<equality-op>);
    }

    method comparison($/){
        make make-node($<term>, $<comparison-op>);
    }

    method term($/){
        make make-node($<factor>, $<term-op>);
    }

    method factor($/){
        make make-node($<unary>, $<factor-op>);
    }

    multi method unary($/ where $<unary-op>) {
        my $op = $<unary-op>.Str;
        my $unary = Unary.new(op => $op, right => $<unary>.made);
        make $unary;
    }

    multi method unary($/ where $<call>){
        make $<call>.made;
    }

    method fun-decl($/) {
        make $<function>.made;
    }

    multi method function($/ where $<parameters>) {
        make Function.new(name => $<identifier>.made.name, params => $<parameters>.made, body => $<block>.made);
    }

    multi method function($/ where !$<parameters>) {
        make Function.new(name => $<identifier>.made.name, params => Nil, body => $<block>.made);
    }


    method parameters($/) {
        make $<identifier>.map: *.made.name;
    }

    multi method call($/ where $<arguments>.elems ge 255) {
        die "Can't have more than 255 arguments.";
    }

    multi method call($/)  {
        my ASTNode @arguments;
        for $<arguments> -> $arg {
            for $arg<expression> -> $expr {
                @arguments.push($expr.made);
            }
        }
        for $<identifier> -> $expr {
            @arguments.push($expr.made);
        }
        make Call.new(callee => $<primary>.made, arguments => @arguments);
    }

    multi method call($/ where $<identifier>) {
        make Call.new(callee => $<primary>.made, arguments => ());
    }

    multi method call($/ where $<left-paren> && !$<arguments> && $<right-paren>) {
        make Call.new(callee => $<primary>.made, arguments => ());
    }

    multi method call($/ where !$<left-paren>){
        make $<primary>.made;
    }

    method return-stmt($/) {
        make Return.new(keyword => "return", value => $<expression>.made);
    }

    multi method if-stmt($/ where !$<else-branch>) {
        make IfStmt.new(condition => $<expression>.made, then-branch => $<statement>.made);
    }

    multi method if-stmt($/) {
        make IfStmtWithElse.new(condition => $<expression>.made, then-branch => $<statement>.made, else-branch => $<else-branch>.made);
    }

    method else-branch($/) {
        make $<statement>.made;
    }

    multi method primary($/ where $<group-expression>){
        make $<group-expression>.made
    }

    multi method primary($/ where !$<group-expression>) {
        my $value = do given $/ {
            when $<boolean> { Literal.new(value => $<boolean>.made) };
            when $<nil> { Literal.new(value => $<nil>.made) };
            when $<this> { $<this>.made };
            when $<number> { Literal.new(value => $<number>.made) };
            when $<string> { Literal.new(value => $<string>.made) };
            when $<identifier> { $<identifier>.made };
            when $<super-class> { $<super-class>.made };
        }
        make $value;
    }

    multi method var-decl($/) {
        # here we only want the name as Str
        make Var.new(name => ~$<identifier>, initializer => $<expression>.made);
    }

    multi method var-decl($/ where !$<assignment-op>) {
        make Var.new(name => ~$<identifier>, initializer => Nothing.new );
    }

    method boolean($/) { make ($/ eq 'true') }
    method nil($/) { make Nil }
    method this($/) { make ~$/ }
    method group-expression($/) {
        make Grouping.new(expression=>$<expression>.made);
    }
    method super-class($/) { $<identifier>.made }


    method minus-op($/) { make ~$/; }

    multi method factor-op($/ where $<division-op>) { make $<division-op>.made; }
    multi method factor-op($/ where $<multiplication-op>) { make $<multiplication-op>.made; }

    method division-op($/) { make ~$/; }
    method multiplication-op($/) { make ~$/; }

    method number($/) {
        make +$/;
    }

    method string($/) {
        make ~$/
    }
}

sub made-if-exists($expression) {
    $expression ?? $expression.made !! Nil;
}

sub make-node(@collection, @ops) returns ASTNode {
    my @ast-nodes of ASTNode = @collection.map: *.made;
    my ASTNode $expr = @ast-nodes.shift;
    for @ast-nodes -> $node {
        $expr = Binary.new(left => $expr, right => $node, op => @ops.shift.Str);
        $expr.op;
    }
    return $expr;
}

sub make-logical-node(@collection, @ops) returns ASTNode {
    my @ast-nodes of ASTNode = @collection.map: *.made;
    my ASTNode $expr = @ast-nodes.shift;
    for @ast-nodes -> $node {
        $expr = Logical.new(left => $expr, right => $node, op => @ops.shift.Str);
        $expr.op;
    }
    return $expr;
}
