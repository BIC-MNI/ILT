#!/usr/local/bin/perl5 -w

    package  PlaneObject;

    use      strict;
    use      vars  qw(@ISA);
    use      ImageInclude;
    @ISA =   ( "SceneObject" );

sub new
{
    my( $proto, $plane_axis, $plane_position ) = @_;

    my $class = ref($proto) || $proto;
    my $self  = {};

    if( defined($plane_axis) && $plane_axis eq "x" )
    {
        $self->{PLANE_NORMAL} = [ 1, 0, 0 ];
        $self->{PLANE_POSITION} = [ $plane_position, 0, 0 ];
    }
    elsif( defined($plane_axis) && $plane_axis eq "y" )
    {
        $self->{PLANE_NORMAL} = [ 0, 1, 0 ];
        $self->{PLANE_POSITION} = [ 0, $plane_position, 0 ];
    }
    elsif( defined($plane_axis) && $plane_axis eq "z" )
    {
        $self->{PLANE_NORMAL} = [ 0, 0, 1 ];
        $self->{PLANE_POSITION} = [ 0, 0, $plane_position ];
    }
    else
    {
        die( "Error in creating plane\n" );
    }

    $self->{TEMP_GEOMETRY_FILE} = undef;

    bless ($self, $class);
    return $self;
}

sub plane_normal
{
    my( $self, $normal ) = @_;

    if( defined($normal) )
    {
        $self->{PLANE_NORMAL} = @$normal;
    }

    return( @{$self->{PLANE_NORMAL}} );
}

sub plane_position
{
    my( $self, $position ) = @_;

    if( defined($position) )
    {
        $self->{PLANE_POSITION} = @$position;
    }

    return( @{$self->{PLANE_POSITION}} );
}

1;
