#!/usr/local/bin/perl5 -w

#----------------------------- MNI Header -----------------------------------
#@NAME       : ColourObject
#@INPUT      : 
#@OUTPUT     : 
#@RETURNS    : 
#@DESCRIPTION: A SceneObject derived class which provides colouring of
#              a sub-object, based on a volume or a solid colour.
#@METHOD     : 
#@GLOBALS    : 
#@CALLS      :  
#@CREATED    : Apr.  3, 1998    David MacDonald
#@MODIFIED   : 
#----------------------------------------------------------------------------

    package  ILT::ColourObject;

    use      strict;
    use      vars  qw(@ISA);
    use      ILT::LayoutInclude;
    use      ILT::LayoutUtils;
    @ISA =   ( "ILT::SceneObject" );

sub new( $ )
{
    my( $proto ) = arg_string( shift );
    end_args( @_ );

    my $class = ref($proto) || $proto;
    my $self  = {};

    bless ($self, $class);

    return $self;
}

#----------------------------- MNI Header -----------------------------------
#@NAME       : new_volume_colouring
#@INPUT      : object
#              volume_object
#              method
#              low_limit
#              high_limit
#@OUTPUT     : 
#@RETURNS    : a ColourObject
#@DESCRIPTION: Creates a ColourObject which assigns colour based on a volume
#@METHOD     : 
#@GLOBALS    : 
#@CALLS      :  
#@CREATED    : Apr.  3, 1998    David MacDonald
#@MODIFIED   : 
#----------------------------------------------------------------------------

sub new_volume_colouring( $$$$$$ )
{
    my( $proto )         = shift;
    my( $object )        = arg_object( shift, "ILT::SceneObject" );
    my( $volume_object ) = arg_object( shift, "ILT::VolumeObject" );
    my( $method )        = arg_enum( shift, N_colour_coding_enums );
    my( $low_limit )     = arg_real( shift );
    my( $high_limit )    = arg_real( shift );
    end_args( @_ );

    my( $self );

    $self = new ILT::ColourObject;

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

sub object_to_colour( $@ )
{
    my( $self )             =  arg_object( shift, "ILT::ColourObject" );
    my( $object_to_colour ) =  opt_arg_object( shift, "ILT::SceneObject" );
    end_args( @_ );

    if( defined($object_to_colour) )
        { $self->{OBJECT_TO_COLOUR} = $object_to_colour; }

    return( $self->{OBJECT_TO_COLOUR} );
}

sub volume( $@ )
{
    my( $self )   =  arg_object( shift, "ILT::ColourObject" );
    my( $volume ) =  opt_arg_object( shift, "ILT::VolumeObject" );
    end_args( @_ );

    if( defined($volume) )
        { $self->{VOLUME} = $volume; }

    return( $self->{VOLUME} );
}

sub method( $@ )
{
    my( $self )   =  arg_object( shift, "ILT::ColourObject" );
    my( $method ) =  opt_arg_enum( shift, N_colour_coding_enums );
    end_args( @_ );

    if( defined($method) )
        { $self->{METHOD} = $method; }

    return( $self->{METHOD} );
}

sub low_limit( $@ )
{
    my( $self )      =  arg_object( shift, "ILT::ColourObject" );
    my( $low_limit ) =  opt_arg_real( shift );
    end_args( @_ );

    if( defined($low_limit) )
        { $self->{LOW_LIMIT} = $low_limit; }

    return( $self->{LOW_LIMIT} );
}

sub high_limit( $@ )
{
    my( $self )      =  arg_object( shift, "ILT::ColourObject" );
    my( $high_limit ) =  opt_arg_real( shift );
    end_args( @_ );

    if( defined($high_limit) )
        { $self->{HIGH_LIMIT} = $high_limit; }

    return( $self->{HIGH_LIMIT} );
}

sub over_colour( $@ )
{
    my( $self )        =  arg_object( shift, "ILT::ColourObject" );
    my( $over_colour ) =  opt_arg_string( shift );
    end_args( @_ );

    if( defined($over_colour) )
        { $self->{OVER_COLOUR} = $over_colour; }

    return( $self->{OVER_COLOUR} );
}

sub under_colour( $@ )
{
    my( $self )        =  arg_object( shift, "ILT::ColourObject" );
    my( $under_colour ) =  opt_arg_string( shift );
    end_args( @_ );

    if( defined($under_colour) )
        { $self->{UNDER_COLOUR} = $under_colour; }

    return( $self->{UNDER_COLOUR} );
}

sub opacity( $@ )
{
    my( $self )    =  arg_object( shift, "ILT::ColourObject" );
    my( $opacity ) =  opt_arg_real( shift, 0, 1 );
    end_args( @_ );

    if( defined($opacity) )
        { $self->{OPACITY} = $opacity; }

    return( $self->{OPACITY} );
}

sub usercc_filename( $@ )
{
    my( $self )            =  arg_object( shift, "ILT::ColourObject" );
    my( $usercc_filename ) =  opt_arg_string( shift );
    end_args( @_ );

    if( defined($usercc_filename) )
        { $self->{USERCC_FILENAME} = $usercc_filename; }

    return( $self->{USERCC_FILENAME} );
}

sub make_ray_trace_args( $ )
{
    my( $self )          =  arg_object( shift, "ILT::ColourObject" );
    end_args( @_ );

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
        { fatal_error( "Incorrect method type in colour object\n" ); }

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

    $full_args = "-reverse_order_colouring $args $object_args -delete_volume 0";

    return( $full_args );
}

sub  get_plane_intersection( $$$$ )
{
    my( $self )              =  arg_object( shift, "ILT::ColourObject" );
    my( $plane_origin_ref )  =  arg_array_ref( shift, 3 );
    my( $plane_normal_ref )  =  arg_array_ref( shift, 3 );
    my( $output_file )       =  arg_string( shift );
    end_args( @_ );

    $self->object_to_colour()->get_plane_intersection(
                                 $plane_origin_ref,
                                 $plane_normal_ref, $output_file );
}

sub compute_bounding_view( $$$$ )
{
    my( $self )                =  arg_object( shift, "ILT::ColourObject" );
    my( $view_direction_ref )  =  arg_array_ref( shift, 3 );
    my( $up_direction_ref )    =  arg_array_ref( shift, 3 );
    my( $transform )           =  arg_string( shift );
    end_args( @_ );

    return( $self->object_to_colour()->compute_bounding_view(
                                            $view_direction_ref,
                                            $up_direction_ref, $transform ) );
}

sub  create_temp_geometry_file( $ )
{
    my( $self )   =  arg_object( shift, "ILT::ColourObject" );
    end_args( @_ );

    $self->object_to_colour()->create_temp_geometry_file();
}

sub  delete_temp_geometry_file( $ )
{
    my( $self )   =  arg_object( shift, "ILT::ColourObject" );
    end_args( @_ );

    $self->object_to_colour()->delete_temp_geometry_file();
}

1;
