#!/usr/local/bin/perl5 -w

# ----------------------------------------------------------------------------
#@COPYRIGHT  :
#              Copyright 1993,1994,1995,1996,1997,1998 David MacDonald,
#              McConnell Brain Imaging Centre,
#              Montreal Neurological Institute, McGill University.
#              Permission to use, copy, modify, and distribute this
#              software and its documentation for any purpose and without
#              fee is hereby granted, provided that the above copyright
#              notice appear in all copies.  The author and McGill University
#              make no representations about the suitability of this
#              software for any purpose.  It is provided "as is" without
#              express or implied warranty.
#-----------------------------------------------------------------------------

#----------------------------- MNI Header -----------------------------------
#@NAME       : ILT::VolumeObject
#@INPUT      : 
#@OUTPUT     : 
#@RETURNS    : 
#@DESCRIPTION: Object class to implement volumes.
#@METHOD     : 
#@GLOBALS    : 
#@CALLS      :  
#@CREATED    : Apr. 16, 1998    David MacDonald
#@MODIFIED   : 
#----------------------------------------------------------------------------

    package  ILT::VolumeObject;

    use      strict;
    use      vars  qw(@ISA);
    use      ILT::LayoutInclude;
    use      ILT::LayoutUtils;
    @ISA =   ( "ILT::SceneObject" );

#--------------------------------------------------------------------------
# define the name of this class
#--------------------------------------------------------------------------

my( $this_class ) = "ILT::VolumeObject";

#----------------------------- MNI Header -----------------------------------
#@NAME       : new
#@INPUT      : prototype
#              volume_filename
#              interpolation
#@OUTPUT     : 
#@RETURNS    : instance of volume object
#@DESCRIPTION: Constructs a volume object
#@METHOD     : 
#@GLOBALS    : 
#@CALLS      :  
#@CREATED    : Apr. 16, 1998    David MacDonald
#@MODIFIED   : 
#----------------------------------------------------------------------------

sub new( $$$ )
{
    my( $proto )           = arg_any( shift );
    my( $volume_filename ) = arg_string( shift );
    my( $interpolation )   = opt_arg_enum( shift, N_interpolation_enums );
    end_args( @_ );

    my $class = ref($proto) || $proto;
    my $self  = {};

    bless ($self, $class);

    if( !defined($interpolation) )
        { $interpolation = Linear_interpolation; }

    $self->filename( $volume_filename );
    $self->interpolation( $interpolation );

    return $self;
}

#----------------------------- MNI Header -----------------------------------
#@NAME       : filename
#@INPUT      : self
#              filename   (OPTIONAL)
#@OUTPUT     : 
#@RETURNS    : filename
#@DESCRIPTION: Returns and optionally sets (if optional argument is present),
#              the name of the file containing the volume.
#@METHOD     : 
#@GLOBALS    : 
#@CALLS      :  
#@CREATED    : Apr. 16, 1998    David MacDonald
#@MODIFIED   : 
#----------------------------------------------------------------------------

sub filename( $$ )
{
    my( $self )     = arg_object( shift, $this_class );
    my( $filename ) = opt_arg_string( shift );
    end_args( @_ );

    if( defined($filename) )
        { $self->{FILENAME} = $filename; }

    return( $self->{FILENAME} );
}

#----------------------------- MNI Header -----------------------------------
#@NAME       : interpolation
#@INPUT      : self
#              interpolation   (OPTIONAL)   : Linear_interpolation, etc.
#@OUTPUT     : 
#@RETURNS    : filename
#@DESCRIPTION: Returns and optionally sets (if optional argument is present),
#              the interpolation method of the volume.
#@METHOD     : 
#@GLOBALS    : 
#@CALLS      :  
#@CREATED    : Apr. 16, 1998    David MacDonald
#@MODIFIED   : 
#----------------------------------------------------------------------------

sub interpolation( $$ )
{
    my( $self )          = arg_object( shift, $this_class );
    my( $interpolation ) = opt_arg_enum( shift, N_interpolation_enums );
    end_args( @_ );

    if( defined($interpolation) )
        { $self->{INTERPOLATION} = $interpolation; }

    return( $self->{INTERPOLATION} );
}

#----------------------------- MNI Header -----------------------------------
#@NAME       : make_ray_trace_args
#@INPUT      : self
#@OUTPUT     : 
#@RETURNS    : string
#@DESCRIPTION: Returns the arguments needed for ray_trace to render this
#              object.  At present there is no rendering method for volumes.
#@METHOD     : 
#@GLOBALS    : 
#@CALLS      :  
#@CREATED    : Apr. 16, 1998    David MacDonald
#@MODIFIED   : 
#----------------------------------------------------------------------------

sub make_ray_trace_args( )
{
    my( $self )          = arg_object( shift, $this_class );
    end_args( @_ );

    return( "" );
}

#----------------------------- MNI Header -----------------------------------
#@NAME       : get_plane_intersection
#@INPUT      : self
#              plane_origin_ref  : ref to array of 3 reals
#              plane_normal_ref  : ref to array of 3 reals
#              output_file
#@OUTPUT     :
#@RETURNS    :
#@DESCRIPTION: Creates the intersection of this object and the specified
#              plane, storing the result in the specified file.
#@METHOD     :
#@GLOBALS    :
#@CALLS      :
#@CREATED    : Apr. 16, 1998    David MacDonald
#@MODIFIED   :
#----------------------------------------------------------------------------

sub  get_plane_intersection( $$$$ )
{
    my( $self )              = arg_object( shift, $this_class );
    my( $plane_origin_ref )  = arg_array_ref( shift, 3 );
    my( $plane_normal_ref )  = arg_array_ref( shift, 3 );
    my( $output_file )       = arg_string( shift );
    end_args( @_ );

    my( @plane_origin, @plane_normal, $command, $n_non_zero, $dim,
        $axis_name, $which );

    @plane_origin = @$plane_origin_ref;
    @plane_normal = @$plane_normal_ref;

    #--------------------------------------------------------------------------
    # determine whether this is x, y, or z oriented plane or arbitrary
    #--------------------------------------------------------------------------

    $n_non_zero = 0;
    for( $dim = 0;  $dim < 3;  ++$dim )
    {
        if( $plane_normal[$dim] != 0 )
            { ++$n_non_zero; $which = $dim; }
    }

    #--------------------------------------------------------------------------
    # if arbitrary orientation, cannot handle this case yet
    #--------------------------------------------------------------------------

    if( $n_non_zero != 1 )
    {
        printf( "Normal: %g %g %g\n", $plane_normal[0], $plane_normal[1],
                $plane_normal[2] );
        fatal_error( "get_plane_intersection() not implemented yet for ".
                     " non-canonical orientations\n" );
    }

    #--------------------------------------------------------------------------
    # make the slice geometry (quadrilateral) for the intersection
    #--------------------------------------------------------------------------

    $axis_name = ( "x", "y", "z" )[$which];

    $command = sprintf( "make_slice %s %s %s w %g 2 2",
                        $self->filename(), $output_file, $axis_name,
                        $plane_origin[$which] );

    system_call( $command );
}

#--------------------------------------------------------------------------

1;
