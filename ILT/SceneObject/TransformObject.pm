#!/usr/local/bin/perl5 -w

    package  TransformObject;

    use      strict;
    use      vars  qw(@ISA);
    use      LayoutInclude;
    use      Utils;
    @ISA =   ( "SceneObject" );

sub new
{
    my( $proto, $sub_object, $transform_filename ) = @_;

    my $class = ref($proto) || $proto;
    my $self  = {};

    bless ($self, $class);

    $self->{SUB_OBJECT} = $sub_object;
    $self->{TRANSFORM_FILE} = $transform_filename;

    return $self;
}

sub sub_object
{
    my( $self, $sub_object ) = @_;

    if( defined($sub_object) )
        { $self->{SUB_OBJECT} = $sub_object; }

    return( $self->{SUB_OBJECT} );
}

sub make_ray_trace_args
{
    my( $self ) = @_;

    my( $args );

    $args = sprintf( "-transform %s %s -transform identity",
                     $self->{TRANSFORM_FILE},
                     $self->{SUB_OBJECT}->make_ray_trace_args() );

    return( $args );
}

sub  get_plane_intersection
{
    my( $self, $plane_origin_ref, $plane_normal_ref, $output_file ) = @_;

    my( $tmp_file, $transform, $trans_origin, $trans_normal );

    $transform = $self->{TRANSFORM_FILE};
    ( $trans_origin, $trans_normal ) = inverse_transform_plane( $transform,
                                                        $plane_origin_ref,
                                                        $plane_normal_ref );

    $tmp_file = get_tmp_file( "obj" );

    $self->{SUB_OBJECT}->get_plane_intersection( $trans_origin,
                                                 $trans_normal, $tmp_file );

    system( "transform_objects $tmp_file $transform $output_file" );

    delete_tmp_file( $tmp_file );
}

sub compute_bounding_view
{
    my( $self, $view_direction_ref, $up_direction_ref, $transform ) = @_;

    my( $x_min, $x_max, $y_min, $y_max, $z_min, $z_max, $sub_object,
        $tmp_transform, $command );

    if( defined( $transform ) )
    {
        $tmp_transform = get_tmp_file( "xfm" );
        $command = sprintf( "xfmconcat -clobber %s %s %s",
                            $transform, $self->{TRANSFORM_FILE}, $tmp_transform );
        system_call( $command );
    }
    else
    {
        $tmp_transform = $self->{TRANSFORM_FILE};
    }

    ( $x_min, $x_max, $y_min, $y_max, $z_min, $z_max ) = 
           $self->{SUB_OBJECT}->compute_bounding_view( $view_direction_ref,
                                                       $up_direction_ref,
                                                       $tmp_transform );
    if( defined($transform) )
    {
        delete_tmp_files( $tmp_transform );
    }

    return( $x_min, $x_max, $y_min, $y_max, $z_min, $z_max );
}

sub  create_temp_geometry_file
{
    my( $self ) = @_;;

    $self->{SUB_OBJECT}->create_temp_geometry_file();
}

sub  delete_temp_geometry_file
{
    my( $self ) = @_;

    $self->{SUB_OBJECT}->delete_temp_geometry_file();
}

1;
