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
#@NAME       : ILT::TextObject
#@INPUT      : 
#@OUTPUT     : 
#@RETURNS    : 
#@DESCRIPTION: An object class to define a text object
#@METHOD     : 
#@GLOBALS    : 
#@CALLS      :  
#@CREATED    : Jun. 23, 1998    David MacDonald
#@MODIFIED   : 
#----------------------------------------------------------------------------

    package  ILT::TextObject;

    use      strict;
    use      vars qw( @ISA );
    use      ILT::LayoutInclude;
    use      ILT::Executables;
    use      ILT::LayoutUtils;
    use      ILT::ProgUtils;
    @ISA = ( "ILT::SceneObject" );

    my( $rcsid ) = '$Header: /private-cvsroot/libraries/ILT/ILT/SceneObject/TextObject.pm,v 1.1 1998-07-21 15:10:35 david Exp $';

#--------------------------------------------------------------------------
# define the name of this class
#--------------------------------------------------------------------------

my( $this_class ) = "ILT::TextObject";

#----------------------------- MNI Header -----------------------------------
#@NAME       : new
#@INPUT      : prototype
#              string
#              x_pos
#              y_pos
#              font     - optional
#@OUTPUT     : 
#@RETURNS    : instance of TextObject
#@DESCRIPTION: Creates a text object, specified by a string and optional
#              viewport coordinates (0 to 1).
#@METHOD     : 
#@GLOBALS    : 
#@CALLS      :  
#@CREATED    : Jun. 23, 1998    David MacDonald
#@MODIFIED   : 
#----------------------------------------------------------------------------

sub new( $$ )
{
    my( $proto )    = arg_any( shift );
    my( $string )   = arg_string( shift );
    my( $x_pos )    = arg_real( shift );
    my( $y_pos )    = arg_real( shift );
    my( $font )     = opt_arg_string( shift );
    end_args();

    my $class = ref($proto) || $proto;
    my $self  = $class->SUPER::new();

    bless ($self, $class);

    if( !defined($font) )
    {
        $font =
              "-adobe-helvetica-medium-r-normal--12-120-75-75-p-67-iso8859-1";
    }

    $self->string( $string );
    $self->viewport_position( $x_pos, $y_pos );
    $self->font( $font );
    $self->colour( "green" );

    return $self;
}

#----------------------------- MNI Header -----------------------------------
#@NAME       : string
#@INPUT      : self
#              string   (OPTIONAL
#@OUTPUT     : 
#@RETURNS    : string
#@DESCRIPTION: Gets and possibly sets (if optional argument present) the
#              string of the text.
#@METHOD     : 
#@GLOBALS    : 
#@CALLS      :  
#@CREATED    : Jun. 23, 1998    David MacDonald
#@MODIFIED   : 
#----------------------------------------------------------------------------

sub string( $@ )
{
    my( $self )     = arg_object( shift, $this_class );
    my( $string ) = opt_arg_string( shift );
    end_args();

    if( defined($string) )
        { $self->{STRING} = $string; $self->_reset_width_and_height();}

    return( $self->{STRING} );
}

#----------------------------- MNI Header -----------------------------------
#@NAME       : viewport_position
#@INPUT      : self
#              viewport_position   (OPTIONAL)
#@OUTPUT     : 
#@RETURNS    : viewport_position
#@DESCRIPTION: Gets and possibly sets (if optional argument present) the
#              viewport_position of the text.
#@METHOD     : 
#@GLOBALS    : 
#@CALLS      :  
#@CREATED    : Jun. 23, 1998    David MacDonald
#@MODIFIED   : 
#----------------------------------------------------------------------------

sub viewport_position( $@ )
{
    my( $self )  = arg_object( shift, $this_class );
    my( @pos )   = opt_arg_array_of_reals( \@_, 2 );
    end_args();

    if( @pos )
        { $self->{X_POS} = $pos[0];  $self->{Y_POS} = $pos[1]; }

    return( $self->{X_POS}, $self->{Y_POS} );
}

#----------------------------- MNI Header -----------------------------------
#@NAME       : font
#@INPUT      : self
#              font   (OPTIONAL)
#@OUTPUT     : 
#@RETURNS    : font
#@DESCRIPTION: Gets and possibly sets (if optional argument present) the
#              font of the text.
#@METHOD     : 
#@GLOBALS    : 
#@CALLS      :  
#@CREATED    : Jun. 23, 1998    David MacDonald
#@MODIFIED   : 
#----------------------------------------------------------------------------

sub font( $@ )
{
    my( $self )  = arg_object( shift, $this_class );
    my( $font )  = opt_arg_string( shift );
    end_args();

    if( defined($font) )
        { $self->{FONT} = $font; $self->_reset_width_and_height(); }

    return( $self->{FONT} );
}

#----------------------------- MNI Header -----------------------------------
#@NAME       : colour
#@INPUT      : self
#              colour   (OPTIONAL)
#@OUTPUT     : 
#@RETURNS    : colour
#@DESCRIPTION: Gets and possibly sets (if optional argument present) the
#              colour of the text.
#@METHOD     : 
#@GLOBALS    : 
#@CALLS      :  
#@CREATED    : Jun. 23, 1998    David MacDonald
#@MODIFIED   : 
#----------------------------------------------------------------------------

sub colour( $@ )
{
    my( $self )    = arg_object( shift, $this_class );
    my( $colour )  = opt_arg_string( shift );
    end_args();

    if( defined($colour) )
        { $self->{COLOUR} = $colour; }

    return( $self->{COLOUR} );
}

sub _get_args( $$$ )
{
    my( $self )             =  arg_object( shift, $this_class );
    my( $viewport_x_size )  =  arg_real( shift, 0, 1e30 );
    my( $viewport_y_size )  =  arg_real( shift, 0, 1e30 );
    end_args( @_ );

    my( $args, $x, $y, $font, $xv, $yv, $colour, $string );

    $font = $self->font();
    $colour = $self->colour();
    $string = $self->string();
    ( $xv, $yv ) = $self->viewport_position();

    print( "Xv: $xv\n" );
    $x = int( $xv * $viewport_x_size + 0.5 );
    $y = int( $yv * $viewport_y_size + 0.5 );

    $args = "-font $font -pen $colour -geometry +${x}+${y} -annotate \"$string\"";

    return( $args );
}

sub  _reset_width_and_height( $ )
{
    my( $self )    = arg_object( shift, $this_class );
    end_args();

    $self->{WIDTH} = undef;
    $self->{HEIGHT} = undef;
}

sub  _determine_width_and_height( $ )
{
    my( $self )    = arg_object( shift, $this_class );
    end_args();

    my( $args, $tmp_file, $string, $font, $out );

    if( defined( $self->{WIDTH} ) && defined( $self->{HEIGHT} ) )
        { return; }

    $string = $self->string();
    if( $string eq "" )
    {
        $self->{HEIGHT} = 0;
        $self->{WIDTH} = 0;
        return;
    }

    $tmp_file = get_tmp_file( "rgb" );
    run_executable( "ray_trace", " -bg white -size 400 200 -output $tmp_file" );

    $font = $self->font();
    $args = "-font $font -pen black -geometry +0x0 -annotate \"$string\"" .
            " -crop 0x0 $tmp_file ";

    run_executable( "mogrify", $args );

    $out = `imginfo $tmp_file`;
    $out =~ /Dimensions.*:\s+(\d+),\s+(\d+),/;

    $self->{HEIGHT} = $1;
    $self->{WIDTH} = $2;

    delete_tmp_files( $tmp_file );
}

#----------------------------- MNI Header -----------------------------------
#@NAME       : height
#@INPUT      : self
#@OUTPUT     : 
#@RETURNS    : the height of the text in pixels
#@DESCRIPTION: Returns the height of the text in pixels.
#@METHOD     : 
#@GLOBALS    : 
#@CALLS      :  
#@CREATED    : Jun. 23, 1998    David MacDonald
#@MODIFIED   : 
#----------------------------------------------------------------------------

sub height( $ )
{
    my( $self )  = arg_object( shift, $this_class );
    end_args();

    $self->_determine_width_and_height();

    return( 20 );
}

#----------------------------- MNI Header -----------------------------------
#@NAME       : width
#@INPUT      : self
#@OUTPUT     : 
#@RETURNS    : the width of the text in pixels
#@DESCRIPTION: Returns the width of the text in pixels.
#@METHOD     : 
#@GLOBALS    : 
#@CALLS      :  
#@CREATED    : Jun. 23, 1998    David MacDonald
#@MODIFIED   : 
#----------------------------------------------------------------------------

sub width( $ )
{
    my( $self )  = arg_object( shift, $this_class );
    end_args();

    $self->_determine_width_and_height();

    return( 20 );
}

#----------------------------- MNI Header -----------------------------------
#@NAME       : make_ray_trace_args
#@INPUT      : self
#@OUTPUT     : 
#@RETURNS    : 
#@DESCRIPTION: Returns a string containing the necessary ray trace arguments
#              for this object, which is simply the filename.
#@METHOD     : 
#@GLOBALS    : 
#@CALLS      :  
#@CREATED    : Jun. 23, 1998    David MacDonald
#@MODIFIED   : 
#----------------------------------------------------------------------------

sub make_ray_trace_args( $ )
{
    my( $self )     = arg_object( shift, $this_class );
    end_args();

    return( "" );
}

#----------------------------- MNI Header -----------------------------------
#@NAME       : compute_bounding_view
#@INPUT      : self
#              view_direction_ref  : ref to array of 3
#              up_direction_ref    : ref to array of 3
#              transform_ref       : filename of a transform file
#@OUTPUT     : 
#@RETURNS    : array of 6 reals
#@DESCRIPTION: Computes the bounding box of the object, given a view
#              direction.
#@METHOD     : 
#@GLOBALS    : 
#@CALLS      :  
#@CREATED    : Jun. 23, 1998    David MacDonald
#@MODIFIED   : 
#----------------------------------------------------------------------------

sub compute_bounding_view( $$$$ )
{
    my( $self )                =  arg_object( shift, $this_class );
    my( $view_direction_ref )  =  arg_array_ref( shift, 3 );
    my( $up_direction_ref )    =  arg_array_ref( shift, 3 );
    my( $transform )           =  arg_string( shift );
    end_args( @_ );

    return( 0, -1, 0, -1, 0, -1 );
}

#----------------------------- MNI Header -----------------------------------
#@NAME       : get_text_image_magick_args
#@INPUT      : self
#@OUTPUT     : 
#@RETURNS    : a string
#@DESCRIPTION: Returns a string which are arguments to pass to the
#              ImageMagick program to do text rendering
#@METHOD     : 
#@GLOBALS    : 
#@CALLS      :  
#@CREATED    : Jun. 23, 1998    David MacDonald
#@MODIFIED   : 
#----------------------------------------------------------------------------

sub get_text_image_magick_args( $$$ )
{
    my( $self )             =  arg_object( shift, $this_class );
    my( $viewport_x_size )  =  arg_real( shift, 0, 1e30 );
    my( $viewport_y_size )  =  arg_real( shift, 0, 1e30 );
    end_args( @_ );

    my( $args, $x, $y, $font, $xv, $yv, $colour, $string );

    $font = $self->font();
    $colour = $self->colour();
    $string = $self->string();
    ( $xv, $yv ) = $self->viewport_position();

    $x = int( $xv * $viewport_x_size + 0.5 );
    $y = int( $yv * $viewport_y_size + 0.5 );

    $self->width();
    $self->height();

    $args = "-font $font -pen $colour -geometry +${x}+${y} -annotate \"$string\"";

    return( $args );
}

1;
