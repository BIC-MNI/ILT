#!/usr/local/bin/perl5 -w

    package  ColourObject;

    use      strict;
    use      vars  qw(@ISA);
    use      ImageInclude;
    use      Utils;
    @ISA =   ( "SceneObject" );

sub new
{
    my( $proto, $object, $volume_object, $method, $low_limit, $high_limit ) =@_;

    my $class = ref($proto) || $proto;
    my $self  = {};

    bless ($self, $class);

    $self->object_to_colour( $object );
    $self->volume( $volume_object );
    $self->method( $method );
    $self->low_limit( $low_limit );
    $self->high_limit( $high_limit );
    $self->under_colour( "black" );
    $self->over_colour( "white" );
    $self->opacity( 1 );

    return $self;
}

sub object_to_colour
{
    my( $self, $object_to_colour ) = @_;

    if( defined($object_to_colour) )
        { $self->{OBJECT_TO_COLOUR} = $object_to_colour; }

    return( $self->{OBJECT_TO_COLOUR} );
}

sub volume
{
    my( $self, $volume ) = @_;

    if( defined($volume) )
        { $self->{VOLUME} = $volume; }

    return( $self->{VOLUME} );
}

sub method
{
    my( $self, $method ) = @_;

    if( defined($method) )
        { $self->{METHOD} = $method; }

    return( $self->{METHOD} );
}

sub low_limit
{
    my( $self, $low_limit ) = @_;

    if( defined($low_limit) )
        { $self->{LOW_LIMIT} = $low_limit; }

    return( $self->{LOW_LIMIT} );
}

sub high_limit
{
    my( $self, $high_limit ) = @_;

    if( defined($high_limit) )
        { $self->{HIGH_LIMIT} = $high_limit; }

    return( $self->{HIGH_LIMIT} );
}

sub over_colour
{
    my( $self, $over_colour ) = @_;

    if( defined($over_colour) )
        { $self->{OVER_COLOUR} = $over_colour; }

    return( $self->{OVER_COLOUR} );
}

sub under_colour
{
    my( $self, $under_colour ) = @_;

    if( defined($under_colour) )
        { $self->{UNDER_COLOUR} = $under_colour; }

    return( $self->{UNDER_COLOUR} );
}

sub opacity
{
    my( $self, $opacity ) = @_;

    if( defined($opacity) )
        { $self->{OPACITY} = $opacity; }

    return( $self->{OPACITY} );
}

sub usercc_filename
{
    my( $self, $usercc_filename ) = @_;

    if( defined($usercc_filename) )
        { $self->{USERCC_FILENAME} = $usercc_filename; }

    return( $self->{USERCC_FILENAME} );
}

sub make_ray_trace_args
{
    my( $self ) = @_;

    my( $args, $method_name, $continuity, $object_args, $full_args );

    if( $self->method() == Gray_scale )
        { $method_name = "-gray"; }
    elsif( $self->method() == Hot_metal_scale )
        { $method_name = "-hot"; }
    elsif( $self->method() == Spectral_scale )
        { $method_name = "-spectral"; }
    elsif( $self->method() == Red_scale )
        { $method_name = "-red"; }
    elsif( $self->method() == Green_scale )
        { $method_name = "-green"; }
    elsif( $self->method() == Blue_scale )
        { $method_name = "-blue"; }
    elsif( $self->method() == Over_colour_scale )
        { $method_name = "-colour"; }
    elsif( $self->method() == Usercc_scale )
        { $method_name = sprintf( "-usercc %s", $self->usercc_filename() );  }
    else
        { clean_up_and_die( "Incorrect method type in colour object\n" ); }

    if( $self->volume()->interpolation() == Nearest_neighbour_interpolation )
        { $continuity = -1; }
    elsif( $self->volume()->interpolation() == Linear_interpolation )
        { $continuity = 0; }
    elsif( $self->volume()->interpolation() == Cubic_interpolation )
        { $continuity = 2; }

    $args = sprintf( "-under %s -over %s %s %g %g %s %d %g",
                     $self->under_colour(),
                     $self->over_colour(), $method_name,
                     $self->low_limit(),
                     $self->high_limit(),
                     $self->volume()->filename(),
                     $continuity, $self->opacity() );

    $object_args = $self->object_to_colour()->make_ray_trace_args();

    $full_args = "$args $object_args -delete_volume 0";

    return( $full_args );
}

sub  get_plane_intersection
{
    my( $self, $plane_origin_ref, $plane_normal_ref, $output_file ) = @_;

    $self->object_to_colour()->get_plane_intersection(
                      $plane_origin_ref,
                      $plane_normal_ref, $output_file );
}

sub compute_bounding_view
{
    my( $self, $view_direction_ref, $up_direction_ref ) = @_;

    return( $self->object_to_colour()->compute_bounding_view(
                                            $view_direction_ref,
                                            $up_direction_ref ) );
}

sub  create_temp_geometry_file
{
    my( $self ) = @_;

    $self->object_to_colour()->create_temp_geometry_file();
}

sub  delete_temp_geometry_file
{
    my( $self ) = @_;

    $self->object_to_colour()->delete_temp_geometry_file();
}

1;
