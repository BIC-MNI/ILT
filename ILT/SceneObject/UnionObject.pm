#!/usr/local/bin/perl5 -w

    package  UnionObject;

    use      strict;
    use      vars  qw(@ISA);
    use      ImageInclude;
    use      Utils;
    @ISA =   ( "SceneObject" );

sub new
{
    my( $proto, @sub_objects ) = @_;

    my $class = ref($proto) || $proto;
    my $self  = {};

    bless ($self, $class);

    $self->{SUB_OBJECTS} = [ @sub_objects ];

    return $self;
}

sub n_sub_objects
{
    my( $self ) = @_;

    return( scalar( @{$self->{SUB_OBJECTS}} ) );
}

sub sub_object
{
    my( $self, $index, $sub_object ) = @_;

    if( defined($sub_object) )
        { $self->{SUB_OBJECTS}[$index] = $sub_object; }

    return( $self->{SUB_OBJECTS}[$index] );
}

sub make_ray_trace_args
{
    my( $self ) = @_;

    my( $args, $sub_args, $sub_object );

    $args = "";

    foreach $sub_object ( @{$self->{SUB_OBJECTS}} )
    {
        $sub_args = $sub_object->make_ray_trace_args();
        $args = $args . " " . $sub_args;
    }

    return( $args );
}

sub  get_plane_intersection
{
    my( $self, $plane_origin_ref, $plane_normal_ref, $output_file ) = @_;

    my( $tmp_file, $sub_object );

    $tmp_file = get_tmp_file( "obj" );

    unlink( $output_file );
    system_call( "touch $output_file" );

    foreach $sub_object ( @{$self->{SUB_OBJECTS}} )
    {
        $sub_object->get_plane_intersection( $plane_origin_ref,
                                             $plane_normal_ref, $tmp_file );

        system_call( "cat $tmp_file >> $output_file" );
    }

    delete_tmp_file( $tmp_file );
}

sub compute_bounding_view
{
    my( $self, $view_direction_ref, $up_direction_ref ) = @_;

    my( $x_min, $x_max, $y_min, $y_max, $z_min, $z_max, $sub_object,
        $sub_x_min, $sub_x_max, $sub_y_min, $sub_y_max,
        $sub_z_min, $sub_z_max, $first );

    $first = 1;

    foreach $sub_object ( @{$self->{SUB_OBJECTS}} )
    {
        ( $sub_x_min, $sub_x_max, $sub_y_min, $sub_y_max,
          $sub_z_min, $sub_z_max ) = 
                    $sub_object->compute_bounding_view( $view_direction_ref,
                                                        $up_direction_ref );

        if( $first )
        {
            ($x_min, $x_max, $y_min, $y_max, $z_min, $z_max) =
            ($sub_x_min, $sub_x_max, $sub_y_min, $sub_y_max,
             $sub_z_min, $sub_z_max );

            $first = 0;
        }
        else
        {
            if( $sub_x_min < $x_min )
                { $x_min = $sub_x_min; }
            if( $sub_y_min < $y_min )
                { $y_min = $sub_y_min; }
            if( $sub_z_min < $z_min )
                { $z_min = $sub_z_min; }

            if( $sub_x_max > $x_max )
                { $x_max = $sub_x_max; }
            if( $sub_y_max > $y_max )
                { $y_max = $sub_y_max; }
            if( $sub_z_max > $z_max )
                { $z_max = $sub_z_max; }
        }
    }

    return( $x_min, $x_max, $y_min, $y_max, $z_min, $z_max );
}

sub  create_temp_geometry_file
{
    my( $self ) = @_;;

    my( $sub_object );

    foreach $sub_object ( @{$self->{SUB_OBJECTS}} )
    {
        $sub_object->create_temp_geometry_file();
    }
}

sub  delete_temp_geometry_file
{
    my( $self ) = @_;

    my( $sub_object );

    foreach $sub_object ( @{$self->{SUB_OBJECTS}} )
    {
        $sub_object->delete_temp_geometry_file();
    }
}

1;
