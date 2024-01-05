use RakuLox::LoxAST;
use RakuLox::LoxEnvironment;
unit class LoxInterpreter;

has LoxEnvironment $.environment = LoxEnvironment.new;

method interpret(@statements) {
    my @result;
    for @statements -> $stmt {
        @result.push(self.evaluate($stmt));
    }
    return @result;
}

multi method evaluate(Print $node) {
    say self.evaluate($node.expression);
}

multi method evaluate(While $node) {
    while self.evaluate($node.condition) {
        self.evaluate($node.body);
    }
}

multi method evaluate(Var $node) {
    $.environment.define($node.name, self.evaluate($node.initializer));
}

multi method evaluate(Nothing $node) {
    "Nothing";
}

multi method evaluate(Variable $node) {
    $.environment.get($node.name);
}

multi method evaluate(Block $node){
    my LoxEnvironment $previous = $.environment;
    try {
        $.environment = LoxEnvironment.new($previous);
    }

    # for $node.statements -> $statement {
    #     self.evaluate($statement);
    # }
}

multi method evaluate(Expression $node) {
    self.evaluate($node.expression);
}

multi method evaluate(ClassDeclaration $node) {
    #    say $node.identifier;
    #say "CLASS Delclaration evaluate";
}

multi method evaluate(ExprStmt $node) {
    #say "ExprStmt evaluate";
    self.evaluate($node.expression);
}

multi method evaluate(Assign $node) {
    my $res = self.evaluate($node.value);
    $.environment.assign($node.name, $res);
    return $res;
}

multi method evaluate(Literal $node) {
    return $node.value;
}

multi method evaluate(Binary $node) {
    my $left = self.evaluate($node.left);
    my $right = self.evaluate($node.right);

    return do given $node.op {
        when "-" {
            self.check-number-operands("-", $left, $right);
            +$left - +$right;
        }
        when "/" {
            self.check-number-operands("/", $left, $right);
            +$left / +$right;
        }
        when "*" {
            self.check-number-operands("*", $left, $right);
            +$left * +$right;
        }
        when "+" {
            self.handle-plus($left, $right);
        }
        when ">" {
            +$left > +$right;
        }
        when ">=" {
            +$left >= +$right;
        }
        when "<" {
            +$left < +$right;
        }
        when "<=" {
            +$left <= +$right;
        }
        when "==" {
            +$left eq +$right;
        }
        when "!=" {
            +$left ne +$right;
        }

    }
}

multi method check-number-operands(Str $op, Numeric $left, Numeric $right){
    # Continue
}

multi method check-number-operands(Str $op, $left, $right){
    die "operator: $op operand must be a number.";
}

multi method handle-plus(Numeric $left, Numeric $right) {
    $left + $right;
}

multi method handle-plus(Str $left, Str $right) {
    $left ~ $right;
}

multi method handle-plus($left, $right) {
    die "Operands must be two numbers or two strings. For + operator";
}

multi method evaluate(Unary $node) {
    my $right = self.evaluate($node.right);
    return do given $node.op {
        when "-" {
            - $right;
        }
        when "!" {
            !$right;
        }
    }
}

multi method evaluate(Grouping $node) {
    self.evaluate($node.expression);
}
