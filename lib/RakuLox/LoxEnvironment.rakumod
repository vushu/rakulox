unit class LoxEnvironment;

has %.values;

method define($name, $value){
    say "defining ", $name ;
    %.values{$name} = $value;
}

method get($name) {
    say "getting name ", $name, %.values;
    if %.values{$name}:exists {
        return %.values{$name};
    }
    else {
        die "Undefined variable $name.";
    }
}
