use RakuLox::LoxAST;
class LoxActions {

    method TOP($/) {
        my $top = Top.new;
        for $<declaration> -> $decl {
            $top.declarations.push($decl.made);
        }
        make $top;
    }

    method declaration($/) {
        make $<declaration>.made;
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

    method expr-stmt($/) {
        make ExprStmt.new($<expression>.made);
    }

    method expression($/) {
        my $assignment = $<assignment>.made;
        make Expression.new(assignment => $assignment);
    }

    multi method assignment($/ where $<logic-or>) {
        say "-> -> -> -> -> -> -> -> -> making logic or";
        make $<logic-or>.made;
    }

    multi method assignment($/ where !$<logic-or>) {
        say "--> --> Paren dot identifier";
        die "Please implement";
    }

    multi method logic-or($/) {
        say "Inside normal logic or ";
        make make-node($<logic-and>, $<or-op>);
    }

    multi method logic-and($/) {
        say "Making logic and";
        make make-node($<equality>, $<and-op>);
    }

    multi method equality($/){
        say "Equality.";
        make make-node($<comparison>, $<equality-op>);
    }

    method comparison($/){
        say "Comparison.";
        make make-node($<term>, $<comparison-op>);
    }

    method term($/){
        say "Term.";
        make make-node($<factor>, $<term-op>);
    }

    method factor($/){
        make make-node($<unary>, $<factor-op>);
    }

    multi method unary($/ where $<minus-op>) {
        my Expr $expr = $<logic-and>[0].made;
        say "Making Unary";
        my $v = $<call>.made;
        my $op = $<minus-op>.map: *.made;
        my $unary = Unary.new(op=>$op, right=> $v);
        make $unary;
    }

    multi method unary($/ where !$<minus-op>){
        make $<call>.made;
    }

    method call($/ where !$<call-tail>) {
        # Skipping call
        make $<primary>.made;
    }

    method primary($/) {
        my $value = do given $/ {
            when $<boolean> { $<boolean>.made };
            when $<nil> { $<nil>.made };
            when $<this> { $<this>.made };
            when $<number> { $<number>.made };
            when $<string> { $<string>.made };
            when $<identifier> { $<identifier>.made };
            when $<group-expression> { $<group-expression>.made };
            when $<super-dot> { $<super-dot>.made };
        }
        make Primary.new(value=> $value);
    }

    method boolean($/) { make ($/ == 'true') }
    method nil($/) { make ~$/ }
    method this($/) { make ~$/ }
    method group-expression($/) { make Grouping.new(expression=>$<expression>.made) }
    method super-class($/) { $<identifier>.made }


    method minus-op($/) {
        make ~$/;
    }

    method number($/) {
        make +$/;
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
