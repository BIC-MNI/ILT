#!/usr/local/bin/perl5 -w

    package  ILT::TransformObject;

    use      strict;
    use      vars  qw(@ISA);
    use      ILT::LayoutInclude;
    use      ILT::LayoutUtils;
    @ISA =   ( "ILT::SceneObject" );

sub new( $$$ )
{
    my( $proto )              = shift;
    my( $sub_object )         = arg_object( shift, "ILT::SceneObject" );
    my( $transform_filename ) = arg_string( shift );
    end_args( @_ );

    my $class = ref($proto) || $proto;
    my $self  = {};

    bless ($self, $class);

    $self->sub_object( $sub_object );
    $self->transform( $transform_filename );

    return $self;
}

sub sub_object( $@ )
{
    my( $self )        = arg_object( shift, "ILT::TransformObject" );
    my( $sub_object )  = opt_arg_object( shift, "ILT::SceneObject" );
    end_args( @_ );

    if( defined($sub_object) )
        { $self->{SUB_OBJECT} = $sub_object; }

    return( $self->{SUB_OBJECT} );
}

sub transform( $@ )
{
    my( $self )        = arg_object( shift, "ILT::TransformObject" );
    my( $transform )  = opt_arg_string( shift );
    end_args( @_ );

    if( defined($transform) )
        { $self->{TRANSFORM_FILENAME} = $transform; }

    return( $self->{TRANSFORM_FILENAME} );
}

sub make_ray_trace_args( $ )
{
    my( $self )        = arg_object( shift, "ILT::TransformObject" );
    end_args( @_ );

    my( $args );

    $args = sprintf( "-transform %s %s -transform identity",
                     $self->transform(),
                     $self->sub_object()->make_ray_trace_args() );

    return( $args );
}

sub  get_plane_intersection( $$$$ )
{
    my( $self )              =  arg_object( shift, "ILT::TransformObject" );
    my( $plane_origin_ref )  =  arg_array_ref( shift, 3 );
    my( $plane_normal_ref )  =  arg_array_ref( shift, 3 );
    my( $output_file )       =  arg_string( shift );
    end_args( @_ );

    my( $tmp_file, $transform, $trans_origin, $trans_normal );

    $transform = $self->transform();
    ( $trans_origin, $trans_normal ) = inverse_transform_plane( $transform,
                                                        $plane_origin_ref,
                                                        $plane_normal_ref );

    $tmp_file = get_tmp_file( "obj" );

    $self->sub_object()->get_plane_intersection( $trans_origin,
                                                 $trans_normal, $tmp_file );

    system( "transform_objects $tmp_file $transform $output_file" );

    delete_tmp_file( $tmp_file );
}

sub compute_bounding_view( $$$$ )
{
    my( $self )                =  arg_object( shift, "ILT::TransformObject" );
    my( $view_direction_ref )  =  arg_array_ref( shift, 3 );
    my( $up_direction_ref )    =  arg_array_ref( shift, 3 );
    my( $transform )           =  arg_string( shift );
    end_args( @_ );

    my( $x_min, $x_max, $y_min, $y_max, $z_min, $z_max, $sub_object,
        $tmp_transform, $command );

    if( defined( $transform ) && $transform ne "" )
    {
        $tmp_transform = get_tmp_file( "xfm" );
        $command = sprintf( "xfmconcat -clobber %s %s %s",
                            $transform, $self->transform(), $tmp_transform );
        system_call( $command );
    }
    else
    {
        $tmp_transform = $self->transform();
    }

    ( $x_min, $x_max, $y_min, $y_max, $z_min, $z_max ) = 
           $self->sub_object()->compute_bounding_view( $view_direction_ref,
                                                       $up_direction_ref,
                                                       $tmp_transform );
    if( defined($transform) )
    {
        delete_tmp_files( $tmp_transform );
    }

    return( $x_min, $x_max, $y_min, $y_max, $z_min, $z_max );
}

sub  create_temp_geometry_file( $ )
{
    my( $self )                =  arg_object( shift, "ILT::TransformObject" );
    end_args( @_ );

    $self->sub_object()->create_temp_geometry_file();
}

sub  delete_temp_geometry_file
{
    my( $self )                =  arg_object( shift, "ILT::TransformObject" );
    end_args( @_ );

    $self->sub_object()->delete_temp_geometry_file();
}

1;
