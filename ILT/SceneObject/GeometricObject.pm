#!/usr/local/bin/perl5 -w

    package  GeometricObject;

    use      strict;
    use      vars qw( @ISA );
    use      LayoutInclude;
    use      Utils;
    @ISA = ( "SceneObject" );

sub new
{
    my( $proto, $filename ) = @_;

    my $class = ref($proto) || $proto;
    my $self  = {};

    $self->{FILENAME} = $filename;

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

sub make_ray_trace_args
{
    my( $self ) = @_;

    my( $filename );

    $filename = $self->{FILENAME};

    return( "$filename" );
}

sub compute_bounding_view
{
    my( $self, $view_direction_ref, $up_direction_ref, $transform ) = @_;

    return( compute_geometry_file_bounding_view( $self->{FILENAME},
                                                 $view_direction_ref,
                                                 $up_direction_ref,
                                                 $transform ) );
}

sub  get_plane_intersection
{
    my( $self, $plane_origin_ref, $plane_normal_ref, $output_file ) = @_;

    my( @plane_origin, @plane_normal, $command );

    @plane_origin = @$plane_origin_ref;
    @plane_normal = @$plane_normal_ref;

#--- the program plane_polygon_intersect needs to be rewritten to be
#--- plane_object_intersect

    $command = sprintf( "plane_polygon_intersect %s %s %g %g %g %g %g %g",
                        $self->filename(), $output_file,
                        $plane_normal[0], $plane_normal[1], $plane_normal[2],
                        $plane_origin[0], $plane_origin[1], $plane_origin[2] );

    system_call( $command );
}

1;
