unit class LoxEnvironment;

has %.values;

method define($name, $value){
    %.values{$name} = $value;
}

method get($name) {
    die "Undefined variable $name." if %.values{$name}:!exists;
    return %.values{$name};
}

method assign($name, $value) {
    die "Undefined variable $name." if %.values{$name}:!exists;
    %.values{$name} = $value;
}
