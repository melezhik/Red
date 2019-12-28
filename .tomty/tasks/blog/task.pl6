use v6;

use Red;

model Person {...}

model Post is rw {
    has Int         $.id        is serial;
    has Int         $.author-id is referencing{ Person.id };
    has Str         $.title     is column{ :unique };
    has Str         $.body      is column;
    has Person      $.author    is relationship{ .author-id };
    has Bool        $.deleted   is column = False;
    has DateTime    $.created   is column .= now;
    has Set         $.tags      is column{
        :type<string>,
        :deflate{ .keys.join: "," },
        :inflate{ set(.split: ",") }
    } = set();
    method delete { $!deleted = True; self.^save }
}

model Person is rw {
    has Int  $.id            is serial;
    has Str  $.name          is column;
    has Post @.posts         is relationship{ .author-id };
    method active-posts { @!posts.grep: not *.deleted }
}

my $*RED-DEBUG          = $_ with %*ENV<RED_DEBUG>;
my $*RED-DEBUG-RESPONSE = $_ with %*ENV<RED_DEBUG_RESPONSE>;
my $*RED-DB             = database "SQLite", |(:database($_) with %*ENV<RED_DATABASE>);

Person.^create-table;
Post.^create-table;

my $p;
$p = Person.^create: :name<Fernando>;

say "\$p.WHAT={$p.^name}"; # Person

say "\$p.name={$p.name}"; # "Fernando";
say "\$p.id.defined={$p.id.defined}";
say "\$p.id={$p.id}"; # 1;

my $post;
$post = $p.posts.create: :title("Red's commit"), :body("Merge branch 'master' of https://github.com/FCO/Red");


say "\$post.WHAT={$post.^name}"; # Post;

#is $post.author-id, $p.id;
say '$post.title=', $post.title; #"Red's commit";
say '$post.body=', $post.body; #"Merge branch 'master' of https://github.com/FCO/Red";

my $post2;
$post2 = $p.posts.create: :title("Another commit"), :body("Blablabla"), :tags(set <bla ble>);
#say $post2.author-id, $p.id;
say '$post2.title=',$post2.title; # "Another commit";
say '$post2.body=',$post2.body; # "Blablabla";
say '$post2.tags=',$post2.tags; # ~~ set <bla ble>;

$post.^delete;
say 'Post.^load($post.id).defined=',"{Post.^load($post.id).defined}";
say 'Post.^load($post.id)=== Nil.new is ',"{Post.^load($post.id) === Nil.new}"; # True

say '$p.active-posts.map(*.id)=',$p.active-posts.map(*.id); # (2);

say '$p.posts.head.created=',$p.posts.head.created.^name; # DateTime;

say "begin multi try test";
for (1 ... 50) {
  say '$p.posts.map(*.tags).head.perl=',$p.posts.map(*.tags).head.perl; # set <bla ble>;
}
say "end multi try test";

