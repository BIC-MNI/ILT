#!/usr/local/bin/perl5 -w

    package  ILT::View;

    use      strict;
    use      ILT::LayoutUtils;

my( $this_class ) = "ILT::View";

sub new( $ )
{
    my( $proto ) = shift;
    end_args( @_ );

    my $class = ref($proto) || $proto;
    my $self  = {};

    bless ($self, $class);

    $self->{VIEW_DIRECTION_ASSIGNED} = 0;
    $self->{UP_DIRECTION_ASSIGNED} = 0;
    $self->{BOUNDING_BOX_ASSIGNED} = 0;

    return $self;
}

sub new_canonical( $$ )
{
    my( $proto )    = shift;
    my( $view )     = arg_enum( shift, N_view_enums );
    end_args( @_ );

    my( $self );

    $self = new ILT::View;

    if( $view == Left_view )
    {
        $self->view_direction( 1, 0, 0 );
        $self->up_direction( 0, 0, 1 );
    }
    elsif( $view == Right_view )
    {
        $self->view_direction( -1, 0, 0 );
        $self->up_direction( 0, 0, 1 );
    }
    elsif( $view == Front_view )
    {
        $self->view_direction( 0, -1, 0 );
        $self->up_direction( 0, 0, 1 );
    }
    elsif( $view == Back_view )
    {
        $self->view_direction( 0, 1, 0 );
        $self->up_direction( 0, 0, 1 );
    }
    elsif( $view == Top_view )
    {
        $self->view_direction( 0, 0, -1 );
        $self->up_direction( 0, 1, 0 );
    }
    elsif( $view == Bottom_view )
    {
        $self->view_direction( 0, 0, 1 );
        $self->up_direction( 0, 1, 0 );
    }
    else
    {
        fatal_error( "Error in View new\n" );
    }

    return $self;
}

sub new_arbitrary( $$$$$$$ )
{
    my( $proto )    = shift;
    my( $x_view )   = arg_real( shift );
    my( $y_view )   = arg_real( shift );
    my( $z_view )   = arg_real( shift );
    my( $x_up )     = arg_real( shift );
    my( $y_up )     = arg_real( shift );
    my( $z_up )     = arg_real( shift );
    end_args( @_ );

    my( $self );

    $self = new ILT::View;

    $self->view_direction( $x_view, $y_view, $z_view );
    $self->up_direction( $x_up, $y_up, $z_up );

    return $self;
}

sub copy( $ )
{
    my( $self ) = shift;
    end_args( @_ );

    my( $copy );

    $copy = new ILT::View;

    $copy->_set_view_direction( $self->view_direction );
    $copy->_set_up_direction( $self->up_direction );

    $copy->{VIEW_DIRECTION_ASSIGNED} = $self->{VIEW_DIRECTION_ASSIGNED};
    $copy->{UP_DIRECTION_ASSIGNED} = $self->{UP_DIRECTION_ASSIGNED};
    $copy->{BOUNDING_BOX_ASSIGNED} = $self->{BOUNDING_BOX_ASSIGNED};

    return( $copy );
}

sub  _set_view_direction( $$$$ )
{
    my( $self )   = arg_object( shift, $this_class );
    my( $x_view ) = arg_real( shift );
    my( $y_view ) = arg_real( shift );
    my( $z_view ) = arg_real( shift );
    end_args( @_ );

    $self->{VIEW_DIRECTION} = [ $x_view, $y_view, $z_view ];
}

sub view_direction
{
    my( $self )           = arg_object( shift, $this_class );
    my( @view_direction ) = opt_arg_array_of_reals( \@_, 3 );
    end_args( @_ );

    if( @view_direction )
    {
        $self->_set_view_direction( @view_direction );
        $self->{VIEW_DIRECTION_ASSIGNED} = 1;
    }

    return( @{$self->{VIEW_DIRECTION}} );
}

sub  _set_up_direction( $$$$ )
{
    my( $self )   = arg_object( shift, $this_class );
    my( $x_up )   = arg_real( shift );
    my( $y_up )   = arg_real( shift );
    my( $z_up )   = arg_real( shift );
    end_args( @_ );

    $self->{UP_DIRECTION} = [ $x_up, $y_up, $z_up ];
}

sub up_direction
{
    my( $self )         = arg_object( shift, $this_class );
    my( @up_direction ) = opt_arg_array_of_reals( \@_, 3 );
    end_args( @_ );

    if( @up_direction )
    {
        $self->_set_up_direction( @up_direction );
        $self->{UP_DIRECTION_ASSIGNED} = 1;
    }

    return( @{$self->{UP_DIRECTION}} );
}

sub  _set_bounding_box( $$$$ )
{
    my( $self )  = arg_object( shift, $this_class );
    my( $x_min ) = arg_real( shift );
    my( $x_max ) = arg_real( shift );
    my( $y_min ) = arg_real( shift );
    my( $y_max ) = arg_real( shift );
    my( $z_min ) = arg_real( shift );
    my( $z_max ) = arg_real( shift );
    end_args( @_ );

    $self->{X_MIN} = $x_min;
    $self->{X_MAX} = $x_max;
    $self->{Y_MIN} = $y_min;
    $self->{Y_MAX} = $y_max;
    $self->{Z_MIN} = $z_min;
    $self->{Z_MAX} = $z_max;
}

sub bounding_box
{
    my( $self )   = arg_object( shift, $this_class );
    my( @bbox )   = opt_arg_array_of_reals( \@_, 6 );
    end_args( @_ );

    if( @bbox )
    {
        $self->_set_bounding_box( @bbox );
        $self->{BOUNDING_BOX_ASSIGNED} = 1;
    }

    return( $self->{X_MIN}, $self->{X_MAX},
            $self->{Y_MIN}, $self->{Y_MAX},
            $self->{Z_MIN}, $self->{Z_MAX} );
}

sub  get_bounding_box_x_min
{
    my( $self )   = arg_object( shift, $this_class );
    end_args( @_ );

    return( $self->{X_MIN} );
}

sub  get_bounding_box_x_max
{
    my( $self )   = arg_object( shift, $this_class );
    end_args( @_ );

    return( $self->{X_MAX} );
}

sub  get_bounding_box_y_min
{
    my( $self )   = arg_object( shift, $this_class );
    end_args( @_ );

    return( $self->{Y_MIN} );
}

sub  get_bounding_box_y_max
{
    my( $self )   = arg_object( shift, $this_class );
    end_args( @_ );

    return( $self->{Y_MAX} );
}

sub  get_bounding_box_z_min
{
    my( $self )   = arg_object( shift, $this_class );
    end_args( @_ );

    return( $self->{Z_MIN} );
}

sub  get_bounding_box_z_max
{
    my( $self )   = arg_object( shift, $this_class );
    end_args( @_ );

    return( $self->{Z_MAX} );
}

sub  get_bounding_box_width
{
    my( $self )   = arg_object( shift, $this_class );
    end_args( @_ );

    return( $self->get_bounding_box_x_max() - $self->get_bounding_box_x_min() );
}

sub  get_bounding_box_height
{
    my( $self )   = arg_object( shift, $this_class );
    end_args( @_ );

    return( $self->get_bounding_box_y_max() - $self->get_bounding_box_y_min() );
}

sub check_compute_view_orientation
{
    my( $self )           = arg_object( shift, $this_class );
    my( $scene_object )   = arg_object( shift, "ILT::SceneObject" );
    end_args( @_ );

    my( $x_view, $y_view, $z_view, $x_up, $y_up, $z_up );

    if( $self->{VIEW_DIRECTION_ASSIGNED} && $self->{UP_DIRECTION_ASSIGNED} )
        { return; }

    if( !$self->{VIEW_DIRECTION_ASSIGNED} &&
        !$self->{UP_DIRECTION_ASSIGNED} )
    {
        ( $x_view, $y_view, $z_view, $x_up, $y_up, $z_up ) =
                                       $scene_object->get_default_view();

        $self->_set_view_direction( $x_view, $y_view, $z_view );
        $self->_set_up_direction( $x_up, $y_up, $z_up );
    }
    else
    {
        fatal_error( "Case not implemented in check_compute_view_orientation" );
    }
}

sub check_compute_bounding_box
{
    my( $self )           = arg_object( shift, $this_class );
    my( $scene_object )   = arg_object( shift, "ILT::SceneObject" );
    end_args( @_ );

    my( @view_direction, @up_direction,
        $x_min, $x_max, $y_min, $y_max, $z_min, $z_max );

    if( $self->{BOUNDING_BOX_ASSIGNED} )
        { return; }


    @view_direction = $self->view_direction();
    @up_direction = $self->up_direction();

    ( $x_min, $x_max, $y_min, $y_max, $z_min, $z_max ) =
           $scene_object->compute_bounding_view( \@view_direction,
                                                 \@up_direction );

    $self->_set_bounding_box( $x_min, $x_max, $y_min, $y_max, $z_min, $z_max );
}

sub  compute_view_for_object
{
    my( $self )           = arg_object( shift, $this_class );
    my( $scene_object )   = arg_object( shift, "ILT::SceneObject" );
    end_args( @_ );

    $self->check_compute_view_orientation( $scene_object );

    $self->check_compute_bounding_box( $scene_object );
}

sub  eye_position
{
    my( $self )           = arg_object( shift, $this_class );
    end_args( @_ );

    my( @view_direction, @up_direction, @horizontal_direction,
        $x_offset, $y_offset, $z_offset, @x_offset, @y_offset, @z_offset,
        @eye, $step_back );

    @view_direction = $self->view_direction();
    @up_direction = $self->up_direction();
    @horizontal_direction = cross_vectors( \@view_direction, \@up_direction );
    @up_direction = cross_vectors( \@horizontal_direction,
                                         \@view_direction );

    @view_direction = normalize_vector( @view_direction );
    @horizontal_direction = normalize_vector( @horizontal_direction );
    @up_direction = normalize_vector( @up_direction );

    $step_back = max( $self->get_bounding_box_x_max() -
                      $self->get_bounding_box_x_min(),
                      $self->get_bounding_box_y_max() -
                      $self->get_bounding_box_y_min(),
                      $self->get_bounding_box_z_max() -
                      $self->get_bounding_box_z_min() );

    $x_offset = ($self->get_bounding_box_x_min() +
                 $self->get_bounding_box_x_max()) / 2;
    $y_offset = ($self->get_bounding_box_y_min() +
                 $self->get_bounding_box_y_max()) / 2;
    $z_offset = $self->get_bounding_box_z_min() - $step_back;

    @x_offset = scale_vector( $x_offset, @horizontal_direction );
    @y_offset = scale_vector( $y_offset, @up_direction );
    @z_offset = scale_vector( $z_offset, @view_direction );

    @eye = add_vectors( \@x_offset, \@y_offset );
    @eye = add_vectors( \@eye, \@z_offset );

    return( @eye );
}

sub  window_width( $$ )
{
    my( $self )           = arg_object( shift, $this_class );
    my( $image_aspect )   = arg_real( shift, 0.0, 1.0e30 );
    end_args( @_ );

    my( $world_x_size, $world_y_size, $window_width );

    $world_x_size = $self->get_bounding_box_x_max() -
                    $self->get_bounding_box_x_min();
    $world_y_size = $self->get_bounding_box_y_max() -
                    $self->get_bounding_box_y_min();

    if( $image_aspect > $world_y_size / $world_x_size )
    {
        $window_width = $world_x_size;
    }
    else
    {
        $window_width = $world_y_size / $image_aspect;
    }

    return( $window_width );
}

1;
