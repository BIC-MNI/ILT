#!/usr/local/bin/perl5 -w

    package  ILT::RenderObject;

    use      strict;
    use      vars  qw(@ISA);
    use      ILT::LayoutInclude;
    use      ILT::LayoutUtils;
    use      ILT::SceneObject::OneSubObject;
    @ISA =   ( "ILT::SceneObject::OneSubObject" );

my( $this_class ) = "ILT::RenderObject";

sub new( $$ )
{
    my( $proto )      = shift;
    my( $sub_object ) = arg_object( shift, "ILT::SceneObject" );
    end_args( @_ );

    my $class = ref($proto) || $proto;
    my $self  = $class->SUPER::new( $sub_object );

    bless ($self, $class);

    return $self;
}

sub line_width( $@ )
{
    my( $self )       = arg_object( shift, $this_class );
    my( $line_width ) = opt_arg_real( shift, 0 );
    end_args( @_ );

    if( defined($line_width) )
        { $self->{LINE_WIDTH} = $line_width; }

    return( $self->{LINE_WIDTH} );
}

sub lighting_state( $@ )
{
    my( $self )           = arg_object( shift, $this_class );
    my( $lighting_state ) = opt_arg_enum( shift, N_boolean_enums );
    end_args( @_ );

    if( defined($lighting_state) )
        { $self->{LIGHTING_STATE} = $lighting_state; }

    return( $self->{LIGHTING_STATE} );
}

sub surface_shading( $@ )
{
    my( $self )            = arg_object( shift, $this_class );
    my( $surface_shading ) = opt_arg_enum( shift, N_shading_enums );
    end_args( @_ );

    if( defined($surface_shading) )
        { $self->{SURFACE_SHADING} = $surface_shading; }

    return( $self->{SURFACE_SHADING} );
}

sub make_ray_trace_args( $ )
{
    my( $self )            = arg_object( shift, $this_class );
    end_args( @_ );

    my( $pre_args, $post_args, $args, $object_args, $full_args );

    $pre_args = "";
    $post_args = "";

    if( defined($self->line_width()) )
    {
        $pre_args = $pre_args . sprintf( " -line_width %g",
                                         $self->line_width() );
        $post_args = $post_args . " -line_width -1";
    }

    if( defined($self->lighting_state()) )
    {
        if( $self->lighting_state() )
        {
            $pre_args = $pre_args . " -light ";
            $post_args = $post_args . " -nolight ";
        }
        else
        {
            $pre_args = $pre_args . " -nolight ";
            $post_args = $post_args . " -nolight ";
        }
    }

    if( defined($self->surface_shading()) )
    {
        if( $self->surface_shading() == Linear_interpolation )
        {
            $pre_args = $pre_args . " -smooth ";
            $post_args = $post_args . " -smooth ";
        }
        else
        {
            $pre_args = $pre_args . " -flat ";
            $post_args = $post_args . " -smooth ";
        }
    }

    $object_args = $self->sub_object()->make_ray_trace_args();

    $full_args = "$pre_args $object_args $post_args" ;

    return( $full_args );
}

sub  get_plane_intersection( $$$$ )
{
    my( $self )              =  arg_object( shift, $this_class );
    my( $plane_origin_ref )  =  arg_array_ref( shift, 3 );
    my( $plane_normal_ref )  =  arg_array_ref( shift, 3 );
    my( $output_file )       =  arg_string( shift );
    end_args( @_ );

    $self->sub_object()->get_plane_intersection( $plane_origin_ref,
                                                 $plane_normal_ref,
                                                 $output_file );
}

sub compute_bounding_view( $$$$ )
{
    my( $self )                =  arg_object( shift, $this_class );
    my( $view_direction_ref )  =  arg_array_ref( shift, 3 );
    my( $up_direction_ref )    =  arg_array_ref( shift, 3 );
    my( $transform )           =  arg_string( shift );
    end_args( @_ );

    return( $self->sub_object()->compute_bounding_view(
                                            $view_direction_ref,
                                            $up_direction_ref, $transform ) );
}

sub  create_temp_geometry_file( $ )
{
    my( $self )                =  arg_object( shift, $this_class );
    end_args( @_ );

    $self->sub_object()->create_temp_geometry_file();
}

sub  delete_temp_geometry_file( $ )
{
    my( $self )                =  arg_object( shift, $this_class );
    end_args( @_ );

    $self->sub_object()->delete_temp_geometry_file();
}

1;
