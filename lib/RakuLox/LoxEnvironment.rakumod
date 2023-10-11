unit class LoxEnvironment;

has %.values;

method define($name, $value){
    %.values{$name} = $value;
}

method get($name) {
    if %.values{$name}:exists {
        return %.values{$name};
    }
    die "Undefined variable $name.";
}
