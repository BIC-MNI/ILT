#!/usr/local/bin/perl5 -w

    package  VolumeObject;

    use      strict;
    use      vars  qw(@ISA);
    use      LayoutInclude;
    use      Utils;
    @ISA =   ( "SceneObject" );

sub new
{
    my( $proto, $volume_filename, $interpolation ) = @_;

    my $class = ref($proto) || $proto;
    my $self  = {};

    $self->{FILENAME} = $volume_filename;

    if( !defined($interpolation) )
        { $interpolation = Linear_interpolation; }

    $self->{INTERPOLATION} = $interpolation;

    bless ($self, $class);
    return $self;
}

sub filename
{
    my( $self, $filename ) = @_;

    if( defined($filename) )
    {
        $self->{FILENAME} = $filename;
    }

    return( $self->{FILENAME} );
}

sub interpolation
{
    my( $self, $interpolation ) = @_;

    if( defined($interpolation) )
    {
        $self->{INTERPOLATION} = $interpolation;
    }

    return( $self->{INTERPOLATION} );
}

sub make_ray_trace_args
{
    return( "" );
}

sub  get_plane_intersection
{
    my( $self, $plane_origin_ref, $plane_normal_ref, $output_file ) = @_;

    my( @plane_origin, @plane_normal, $command, $n_non_zero, $dim,
        $axis_name, $which );

    @plane_origin = @$plane_origin_ref;
    @plane_normal = @$plane_normal_ref;

    $n_non_zero = 0;
    for( $dim = 0;  $dim < 3;  ++$dim )
    {
        if( $plane_normal[$dim] != 0 )
            { ++$n_non_zero; $which = $dim; }
    }

    if( $n_non_zero != 1 )
    {
        clean_up_and_die( "get_plane_intersection() not implemented yet for ".
                          " non-canonical orientations\n" );
    }

    $axis_name = ( "x", "y", "z" )[$which];

    $command = sprintf( "make_slice %s %s %s w %g 2 2",
                        $self->filename(), $output_file, $axis_name,
                        $plane_origin[$which] );

    system_call( $command );
}

1;
