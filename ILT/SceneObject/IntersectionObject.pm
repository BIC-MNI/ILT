#!/usr/local/bin/perl5 -w

    package  IntersectionObject;

    use      strict;
    use      vars  qw(@ISA);

    use      LayoutInclude;
    use      Utils;

    @ISA = ( "SceneObject" );

#
#  The intersection object would intersect n objects.  Initially, it would
#  only support intersection of a SliceObject with a SceneObject.
#

sub new
{
    my( $proto, $plane_object, $second_object ) = @_;

    my $class = ref($proto) || $proto;
    my $self  = {};

    $self->{SUB_OBJECTS} = [ $plane_object, $second_object ];

    bless ($self, $class);
    return $self;
}

sub get_n_sub_objects
{
    my( $self ) = @_;

    return( scalar( @{$self->{SUB_OBJECTS}} ) );
}

sub sub_object
{
    my( $self, $object_index, $sub_object ) = @_;

    if( defined( $sub_object ) )
    {
        $self->{SUB_OBJECTS}[$object_index] = $sub_object;
    }

    return( $self->{SUB_OBJECTS}[$object_index] );
}

sub  create_temp_geometry_file
{
    my( $self ) = @_;

    my( $tmp_file, @plane_position, @plane_normal );

    if( defined( $self->{TEMP_GEOMETRY_FILE} ) )
        { return; }

    $tmp_file = get_tmp_file( "obj" );

    @plane_position = $self->{SUB_OBJECTS}[0]->plane_position();
    @plane_normal = $self->{SUB_OBJECTS}[0]->plane_normal();

    $self->{SUB_OBJECTS}[1]->get_plane_intersection(
                   \@plane_position, \@plane_normal, $tmp_file );

    $self->{TEMP_GEOMETRY_FILE} = $tmp_file;
}

sub  delete_temp_geometry_file
{
    my( $self ) = @_;

    my( $sub_object );

    if( defined( $self->{TEMP_GEOMETRY_FILE} ) )
    {
        delete_tmp_files( $self->{TEMP_GEOMETRY_FILE} );
        $self->{TEMP_GEOMETRY_FILE} = undef;
    }
}

sub  compute_bounding_view
{
    my( $self, $view_direction_ref, $up_direction_ref, $transform ) = @_;

    $self->create_temp_geometry_file();

    return( compute_geometry_file_bounding_view( $self->{TEMP_GEOMETRY_FILE},
                              $view_direction_ref, $up_direction_ref,
                              $transform ) );
}

sub  make_ray_trace_args
{
    my( $self ) = @_;

    my( $filename );

    $self->create_temp_geometry_file();

    $filename = $self->{TEMP_GEOMETRY_FILE};

    return( $filename );
}

1;
