#!/usr/local/bin/perl5 -w

    package  ImageInfo;

    use      strict;
    use      View;
    use      Utils;
    use      SceneObject;
    use      SceneObject::GeometricObject;
    use      SceneObject::PlaneObject;
    use      SceneObject::IntersectionObject;

    my( $ray_trace_exec ) = "ray_trace";

sub new
{
    my( $proto, $scene_object, $view ) = @_;

    my $class = ref($proto) || $proto;
    my $self  = {};

    $self->{OBJECT} = $scene_object;
    $self->{VIEW} = $view->copy();

    bless ($self, $class);
    return $self;
}

sub scene_object
{
    my( $self, $scene_object ) = @_;

    if( defined($scene_object) )
    {
        $self->{OBJECT} = $scene_object;
    }

    return( $self->{OBJECT} );
}

sub scene_view
{
    my( $self, $view ) = @_;

    if( defined($view) )
    {
        $self->{VIEW} = $view->copy();
    }

    return( $self->{VIEW} );
}

sub background_colour
{
    my( $self, $background_colour ) = @_;

    if( defined($background_colour) )
    {
        $self->{BACKGROUND_COLOUR} = $background_colour;
    }

    return( $self->{BACKGROUND_COLOUR} );
}

sub create_image
{
    my( $self, $filename, $x_size, $y_size, $view ) = @_;

    my( $geom_args, $view_args, $command,
        @view_direction, @up_direction, @eye, $window_width, $bg );

    $geom_args = $self->{OBJECT}->make_ray_trace_args();

    @view_direction = $view->view_direction();
    @up_direction = $view->up_direction();
    @eye = $view->eye_position();
    $window_width = $view->window_width( $y_size, $x_size );

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
