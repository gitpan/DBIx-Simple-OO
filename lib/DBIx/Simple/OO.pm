package DBIx::Simple::OO;

use strict;
use vars qw[$VERSION];

$VERSION = 0.02;

use DBIx::Simple;

if ($DBIx::Simple::VERSION >= 1.33) {
    # Monkey patch an @ISA instead of ::Result for recent versions of
    # DBIx::Simple, because they support ->object and ->objects out of the
    # box -- but with a different class name.

    push @DBIx::Simple::Result::RowObject::ISA, 'DBIx::Simple::OO::Item';
} else {

=head1 NAME

DBIx::Simple::OO

=head1 SYNOPSIS

    use DBIx::Simple;
    use DBIx::Simple::OO;           # adds OO methods

    $db     = DBIx::Simple->connect( ... );
    $query  = 'select id,name,age from people';

    $res    = $db->query( $query );

    $obj    = $res->object;
    @obj    = $res->objects;

    $id     = $obj->id;             # get the value for field 'id'
    $name   = $obj->name;           # get the value for field 'name'
    $age    = $obj->age;            # get the value for field 'age'

    @acc    = $obj->ls_accessors;   # get a list of all fields
    $sub    = $obj->can('name');    # check if this object has a 
                                    # 'name' method
                                    
    ### add a method to every object that will be returned
    ### by DBIx::Simple::OO
    {   package DBIx::Simple::OO::Item;
        sub has_valid_id { return shift->id !~ /\D/ ? 1 : 0 }
    }
    $bool   = $obj->has_valid_id;

=head1 DESCRIPTION

B<DBIx::Simple now has support for C<object> and C<objects> built into
it.> I<Using DBIx::Simple::OO is no longer necessary if you change
C<DBIx::Simple::OO::Item> to C<DBIx::Simple::Result::RowObject> and
use 1.33 or newer. DBIx::Simple::OO 0.02 implements a work-around to
avoid name clashes, but using 0.01 with DBIx::Simple 1.33+ could go
wrong.>

This module provides a possibility to retrieve rows from a 
database as objects, rather than the traditional C<array ref>
or C<hash ref>. This provides all the usual benefits of using
objects over plain references for accessing data, as well as
allowing you to add methods of your own choosing for data
retrieval.

=head1 HOW IT WORKS

C<DBIx::Simple::OO> declares its 2 methods in the C<DBIx::Simple::Result>
namespace, transforming the rows retrieved from the database to
full fledged objects.

=cut

### the retrieval methods are in the DBIx::Simple::Result package

=head1 METHODS

This module subclasses C<DBIx::Simple> and only adds the following
methods. Any other method, like the C<new> call should be looked up
in the C<DBIx::Simple> manpage instead.

=head2 $obj = $db->query(....)->object( );

Returns the first result from your query as an object.

=cut

    *DBIx::Simple::Result::object = sub {
        my $self = shift or return;

        return $self->_href_to_obj( $self->hash );
    };

=head2 @objs = $db->query(....)->objects( );

Returns the results from your query as a list of objects.

=cut

    *DBIx::Simple::Result::objects = sub {
        my $self = shift or return;
     
        return map { $self->_href_to_obj( $_ ) } $self->hashes;
    };

    ### convert the hashref to a nice O::A object
}

*DBIx::Simple::Result::_href_to_obj = sub {
    my $self = shift or return;
    my $href = shift or return;
    
    my $obj  = DBIx::Simple::OO::Item->new;
    
    ### create accessors for every hash key
    $obj->mk_accessors( keys %$href );
    
    ### and set the value
    for my $acc ( $obj->ls_accessors ) {
        $obj->$acc( $href->{$acc} );
    }

    return $obj;
};

=head1 ACCESSORS

All objects returned by the above methods are from the 
C<DBIx::Simple::OO::Item> class, which subclasses 
C<Object::Accessor>.

The most important methods are described in the synopsis, but
you should refer to the C<Object::Accessor> manpage for more
extensive documentation.

Note that it is possible to declare methods into the
C<DBIx::Simple::OO::Item> class to extend the functionality 
of the objects returned by C<DBIx::Simple::OO>, as also 
described in the C<SYNOPSIS>

=cut

### a full on inherited O::A class
package DBIx::Simple::OO::Item;

use base 'Object::Accessor';

1;

=head1 AUTHOR

This module by
Jos Boumans E<lt>kane@cpan.orgE<gt>.

=head1 COPYRIGHT

This module is
copyright (c) 2005 Jos Boumans E<lt>kane@cpan.orgE<gt>.
All rights reserved.

This library is free software;
you may redistribute and/or modify it under the same
terms as Perl itself.

=cut
