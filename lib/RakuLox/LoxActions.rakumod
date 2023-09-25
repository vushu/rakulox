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
        say "Inside logic or";
        make LogicOr.new(left=>$<logic-and>[0].made,
        op=> $<op>.Str, right=> $<logic-and>[1].made);
    }

    multi method logic-or($/ where $<logic-and>.elems == 1) {
        # Skipping logic since no logic
        say "Skipping logic-or.";
        make $<logic-and>.first.made;
    }

    multi method logic-and($/ where $<equality>.elems == 1){
        say "Skipping logic-and.";
        make $<equality>.first.made;
    }

    multi method equality($/ where $<comparison>.elems == 1){
        say "Skipping equality.";
        make $<comparison>.first.made;
    }

    method comparison($/ where $<term>.elems == 1){
        say "Skipping comparison.";
        make $<term>.first.made;
    }

    method term($/ where $<factor>.elems == 1){
        say "Skipping term.";
        make $<factor>.first.made;
    }

    method factor($/ where $<unary>.elems == 1){
        say "Skipping factor.";
        make $<unary>.first.made;
    }

    method unary($/) {

        say "Making Unary";
        my $v = $<call>.made;
        my $op = $<minus-op>.map: *.made;
        my $unary = Unary.new($op, $v);
        make $unary;
    }

    method call($/) {
        make $<primary>.made;
    }

    method primary($/) {
        make $<number>.made;
    }

    method minus-op($/) {
        make ~$/;
    }

    method number($/) {
        make +$/;
    }

}
