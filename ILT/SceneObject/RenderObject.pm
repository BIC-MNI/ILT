#!/usr/local/bin/perl5 -w

    package  RenderObject;

    use      strict;
    use      vars  qw(@ISA);
    use      LayoutInclude;
    use      Utils;
    @ISA =   ( "SceneObject" );

sub new
{
    my( $proto, $sub_object ) = @_;

    my $class = ref($proto) || $proto;
    my $self  = {};

    bless ($self, $class);

    $self->sub_object( $sub_object );

    return $self;
}

sub sub_object
{
    my( $self, $sub_object ) = @_;

    if( defined($sub_object) )
        { $self->{SUB_OBJECT} = $sub_object; }

    return( $self->{SUB_OBJECT} );
}

sub line_width
{
    my( $self, $line_width ) = @_;

    if( defined($line_width) )
        { $self->{LINE_WIDTH} = $line_width; }

    return( $self->{LINE_WIDTH} );
}

sub lighting_state
{
    my( $self, $lighting_state ) = @_;

    if( defined($lighting_state) )
        { $self->{LIGHTING_STATE} = $lighting_state; }

    return( $self->{LIGHTING_STATE} );
}

sub surface_shading
{
    my( $self, $surface_shading ) = @_;

    if( defined($surface_shading) )
        { $self->{SURFACE_SHADING} = $surface_shading; }

    return( $self->{SURFACE_SHADING} );
}

sub make_ray_trace_args
{
    my( $self ) = @_;

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

sub  get_plane_intersection
{
    my( $self, $plane_origin_ref, $plane_normal_ref, $output_file ) = @_;

    $self->sub_object()->get_plane_intersection(
                      $plane_origin_ref,
                      $plane_normal_ref, $output_file );
}

sub compute_bounding_view
{
    my( $self, $view_direction_ref, $up_direction_ref, $transform ) = @_;

    return( $self->sub_object()->compute_bounding_view(
                                            $view_direction_ref,
                                            $up_direction_ref, $transform ) );
}

sub  create_temp_geometry_file
{
    my( $self ) = @_;

    $self->sub_object()->create_temp_geometry_file();
}

sub  delete_temp_geometry_file
{
    my( $self ) = @_;

    $self->sub_object()->delete_temp_geometry_file();
}

1;
