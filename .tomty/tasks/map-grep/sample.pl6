use Red;

model M is table<mmm> {
   has Str $.a is column;
   has Bool $.b is column;
}

my $*RED-DB = database "SQLite";
M.^create-table;
my $*RED-DEBUG = True;

say M.^all.map: { .a if .b }

