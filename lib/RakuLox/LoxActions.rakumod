use RakuLox::LoxAST;
class LoxActions {

    method TOP($/) {
        my @statements;
        my $top = Top.new;
        for $<declaration> -> $decl {
            # $top.declarations.push($decl.made);
            @statements.push($decl.made);
        }
        # make $top;
        make @statements;
    }

    method declaration($/) {
        make $<declaration>.made;
    }

    #multi method statement($/ where $<print-stmt>){
        #say "print statmement";
        #make $<print-stmt>.made;
    #}

    method block($/) {
        make Block.new(statements => $<declaration>.map: *.made);
    }

    method statement($/){
        make $<statement>.made;
    }

    method class-decl ($/) {
        make ClassDeclaration.new(identifier => $<identifier>[0].made);
    }

    method identifier ($/) {
        make ~$/;
    }

    method while-stmt($/) {
        make While.new(condition => $<expression>.made, body => $<statement>.made);
    }

    method print-stmt($/) {
        say "making print";
        make Print.new(expression => $<expression>.made);
    }

    method expr-stmt($/) {
        make Expression.new(expression => $<expression>.made);
    }

    method expression($/) {
        make $<assignment>.made;
    }

    multi method assignment($/ where $<assignment>) {
        make Assign.new(name=> 'name', value=> $<logic-or>.made);
    }

    multi method assignment($/) {
        make $<logic-or>.made;
    }

    multi method assignment($/ where !$<logic-or>) {
        #say "Paren dot identifier";
        die "Please implement";
    }

    multi method logic-or($/) {
        #say "Inside normal logic or ";
        make make-node($<logic-and>, $<or-op>);
    }

    multi method logic-and($/) {
        #say "Making logic and";
        make make-node($<equality>, $<and-op>);
    }

    multi method equality($/){
        make make-node($<comparison>, $<equality-op>);
    }

    method comparison($/){
        #say "Comparison. ";
        make make-node($<term>, $<comparison-op>);
    }

    method term($/){
        #say "Term. ";
        make make-node($<factor>, $<term-op>);
    }

    method factor($/){
        #say "Factor ", $<factor-op>;
        make make-node($<unary>, $<factor-op>);
    }

    multi method unary($/ where $<unary-op>) {
        my $op = $<unary-op>.Str;
        my $unary = Unary.new(op => $op, right => $<call>.made);
        make $unary;
    }

    multi method unary($/ where !$<unary-op>){
        make $<call>.made;
    }

    method call($/ where !$<call-tail>) {
        # Skipping call
        make $<primary>.made;
    }

    multi method primary($/ where $<group-expression>){
        make $<group-expression>.made
    }

    multi method primary($/ where !$<group-expression>) {
        my $value = do given $/ {
            when $<boolean> { $<boolean>.made };
            when $<nil> { $<nil>.made };
            when $<this> { $<this>.made };
            when $<number> { $<number>.made };
            when $<string> { $<string>.made };
            when $<identifier> { $<identifier>.made };
            when $<super-class> { $<super-class>.made };
        }
        make Literal.new(value=> $value);
    }

    method boolean($/) { make ($/ eq 'true') }
    method nil($/) { make ~$/ }
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
        make ~$<string-content>;
    }
}

sub make-node(@collection, @ops) returns Expr {
    my @ast-nodes of Expr = @collection.map: *.made;
    my Expr $expr = @ast-nodes.shift;
    for @ast-nodes -> $node {
        $expr = Binary.new(left => $expr, right => $node, op => @ops.shift.Str);
        $expr.op;
    }
    return $expr;
}
