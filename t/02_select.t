use Test::More 'no_plan';
use strict;

BEGIN { 
    chdir 't' if -d 't'; 
    
    use File::Spec;
    use lib File::Spec->catdir(qw[.. lib]), 'inc';

    require 'conf.pl';
}

### dummy package declaration to return some 
{   package DBIx::Simple::Result::Mock;
    push @DBIx::Simple::Result::Mock::ISA, 'DBIx::Simple::Result';
   
    my $counter = 0; 

    ### declare the DBIx::Simple::Result methods
    sub _die { }

    # DBIx::Simple >= 1.33
    sub array   { return [ 1, 2 ] if ++$counter < 4; return; }
    sub columns { return 'a', 'b' }

    # DBIx::Simple <= 1.32
    sub hash    { return { a => 1, b => 2 } }
    sub hashes  { return { a => 1 }, { b => 2 } }
}    


my $Class   = 'DBIx::Simple::OO';
my $OClass  = $Class . '::Item';

my $RObj = bless {}, 'DBIx::Simple::Result::Mock';

use_ok( $Class );

{   my %meth = (            # amount of objects returned
        object      => 1,   
        objects     => 2,
    );            

    while (my ($meth,$cnt) = each %meth) {

        can_ok( $RObj,         $meth );

        my @res = $RObj->$meth( );
        is( scalar(@res), $cnt, "   Got $cnt results for '$meth'" );
        
        for my $obj (@res) {
            ok( $obj,           "   Retrieved object" );

            ### ... isa foo will be added by Test::More
            isa_ok( $obj, $OClass,
                                "       Object" );
        
            my @acc = $obj->ls_accessors;
            ok( scalar(@acc),   "       Accessors retrieved" );
        }
    }
}    
