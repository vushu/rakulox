use RakuLox::LoxAST;
use RakuLox::LoxEnvironment;

unit class LoxInterpreter;

class LoxCallable {
    method arity {
        die "Please implement me";
    }
    method call(LoxInterpreter $interpreter, @arguments) {
        die "Please implement me";
    }
}

class LoxFunction is LoxCallable {
    has Function $.declaration;

    method call(LoxInterpreter $interpreter, @arguments) {
        my LoxEnvironment $environment = LoxEnvironment.new;
        for $.declaration.params.kv -> $idx, $v {
            $environment.define($v, @arguments[$idx]);
        }
        $interpreter.execute-block($.declaration.body, $environment);
    }

    method arity {
        $.declaration.params.elems;
    }
}


has LoxEnvironment $.globals is rw = LoxEnvironment.new;
has LoxEnvironment $.environment is rw = $!globals;

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
    return Nil;
}

multi method evaluate(Var $node) {
    $.environment.define($node.name, self.evaluate($node.initializer));
}

multi method evaluate(Nothing $node) {
    "Nothing";
}

multi method evaluate(Variable $node) {
    my $res = $.environment.get($node.name);
    $res;
}

method execute-block(@statements, LoxEnvironment $environment){
    my LoxEnvironment $previous = $.environment;
    try {
        $.environment = $environment;
        for @statements -> $statement {
            self.evaluate($statement);
        }
    }
    LEAVE  {
        $.environment = $previous;
    }
}

multi method evaluate(Block $node){
    self.execute-block($node.statements, LoxEnvironment.new($.environment));
}

multi method evaluate(Expression $node) {
    self.evaluate($node.expression);
}

multi method evaluate(ClassDeclaration $node) {
    #    say $node.identifier;
    #say "CLASS Delclaration evaluate";
}

multi method evaluate(ExprStmt $node) {
    self.evaluate($node.expression);
}

multi method evaluate(Assign $node) {
    my $value = self.evaluate($node.value);
    $.environment.assign($node.name, $value);
    return $value;
}

multi method evaluate(Literal $node) {
    return $node.value;
}

multi method evaluate(Logical $node) {
    my $left = self.evaluate($node.left);
    # if left operand is true then the or-expr is all together true
    return $left if $node.op eq "or" and $left;
    # if left operand is false then the and-expr is all together false
    return $left if $node.op eq "and" and not $left;
    # continue by evaluating the right
    return self.evaluate($node.right);
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

multi method evaluate(IfStmt $stmt) {
    if (self.evaluate($stmt.condition)) {
        self.evaluate($stmt.then-branch);
    }
    return Nil;
}

multi method evaluate(IfStmtWithElse $stmt) {
    if (self.evaluate($stmt.condition)) {
        self.evaluate($stmt.then-branch);
    }
    else {
        self.evaluate($stmt.else-branch);
    }
    return Nil;
}

multi method evaluate(Arguments $node) {
    my @arguments;
    for $node.arguments -> $arg {
        @arguments.push(self.evaluate($arg));
    }
    return @arguments;
   
}

multi method evaluate(Function $node) {
    my LoxFunction $function = LoxFunction.new(declaration => $node);
    $.environment.define($node.name, $function);
}

multi method evaluate(Call $node) {
    my $function = self.evaluate($node.callee);
    # say $node.callee.WHAT;
    # self.call($function, Nil);


    $function.call(self, [Nothing.new]);
}

multi method evaluate(Call $node where $node.arguments) {
    my $function = self.evaluate($node.callee);
    my @evaluated_arguments = $node.arguments.map({self.evaluate($_)});
    if @evaluated_arguments.elems ne $function.arity {
        die "Expected $($function.arity) arguments but got $(@evaluated_arguments.elems)."
    }
    # self.call($function, @evaluated_arguments);
    $function.call(self, @evaluated_arguments)
}

multi method call($not-function-nor-class, \_) {
    # say $not-function-nor-class;
    die "Can only call function and classes and not of type ", $not-function-nor-class.^name;
}

multi method call(LoxInterpreter::LoxFunction $func, @arguments) {
    $func.call(self, @arguments);
}

