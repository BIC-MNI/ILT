#!/usr/local/bin/perl5 -w

    package  ILT::ImageInfo;

    use      strict;
    use      ILT::LayoutUtils;
    use      ILT::LayoutInclude;

my( $this_class ) = "ILT::ImageInfo";
my( $ray_trace_exec ) = "ray_trace";

sub new( $$$ )
{
    my( $proto )        = shift;
    my( $scene_object ) = arg_object( shift, "ILT::SceneObject" );
    my( $view )         = arg_object( shift, "ILT::View" );

    my $class = ref($proto) || $proto;
    my $self  = {};

    bless ($self, $class);

    $self->scene_object( $scene_object );
    $self->scene_view( $view );

    return( $self );
}

sub scene_object( $@ )
{
    my( $self )         = arg_object( shift, $this_class );
    my( $scene_object ) = opt_arg_object( shift, "ILT::SceneObject" );
    end_args( @_ );

    if( defined($scene_object) )
        { $self->{OBJECT} = $scene_object; }

    return( $self->{OBJECT} );
}

sub scene_view( $@ )
{
    my( $self ) = arg_object( shift, $this_class );
    my( $view ) = opt_arg_object( shift, "ILT::View" );
    end_args( @_ );

    if( defined($view) )
        { $self->{VIEW} = $view; }

    return( $self->{VIEW} );
}

sub background_colour( $@ )
{
    my( $self )              = arg_object( shift, $this_class );
    my( $background_colour ) = opt_arg_string( shift );
    end_args( @_ );

    if( defined($background_colour) )
        { $self->{BACKGROUND_COLOUR} = $background_colour; }

    return( $self->{BACKGROUND_COLOUR} );
}

sub create_image( $$$$$ )
{
    my( $self )       = arg_object( shift, $this_class );
    my( $filename )   = arg_string( shift );
    my( $x_size )     = arg_int( shift, 1, 1e30 );
    my( $y_size )     = arg_int( shift, 1, 1e30 );
    my( $view )       = arg_object( shift, "ILT::View" );

    my( $geom_args, $view_args, $command,
        @view_direction, @up_direction, @eye, $window_width, $bg );

    $geom_args = $self->{OBJECT}->make_ray_trace_args();

    @view_direction = $view->view_direction();
    @up_direction = $view->up_direction();
    @eye = $view->eye_position();
    $window_width = $view->window_width( $y_size / $x_size );

    $view_args = sprintf( "-ortho -view %g %g %g %g %g %g " .
                          " -eye %g %g %g " .
                          " -window_width %g" ,
                          $view_direction[0],
                          $view_direction[1],
                          $view_direction[2],
                          $up_direction[0],
                          $up_direction[1],
                          $up_direction[2],
                          $eye[0], $eye[1], $eye[2], $window_width );

    if( defined($self->background_colour() ) )
        { $bg = sprintf( "-bg %s", $self->background_colour() ); }
    else
        { $bg = ""; }

    $command = "$ray_trace_exec -output $filename -nolight $bg " .
               " -size $x_size $y_size " .
               " $view_args " .
               " $geom_args ";

    system_call( $command );
}

1;
