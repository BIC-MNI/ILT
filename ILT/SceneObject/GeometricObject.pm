#!/usr/local/bin/perl5 -w

    package  SceneObject::GeometricObject;

    use      strict;
    use      vars qw( @ISA );
    use      SceneObject;
    @ISA = ( "SceneObject" );

sub new
{
    my( $proto, $filename ) = @_;

    my $class = ref($proto) || $proto;
    my $self  = {};

    $self->{FILENAME} = $filename;

    bless ($self, $class);
    return $self;
}

sub filename
{
    my( $self, $filename ) = @_;

    if( defined($filename) )
    {
        $self->{FILENAME} = $filename;
    }

    return( $self->{FILENAME} );
}

sub make_ray_trace_args
{
    my( $self ) = @_;

    my( $filename );

    $filename = $self->{FILENAME};

    return( "$filename", () );
}

sub get_bounding_box
{
    my( $self, $view_direction_ref, $up_direction_ref ) = @_;

    my( $filename, @view_direction, @up_direction, $command,
        $x_centre, $y_centre, $z_centre, $out,
        $x_min, $x_max, $y_min, $y_max, $z_min, $z_max );

    $filename = $self->{FILENAME};
    @view_direction = @$view_direction_ref;
    @up_direction = @$up_direction_ref;

    $command = sprintf( "compute_bounding_view %s %g %g %g %g %g %g",
                        $filename,
                        $view_direction[0],
                        $view_direction[1],
                        $view_direction[2],
                        $up_direction[0],
                        $up_direction[1],
                        $up_direction[2] );

    print( "$command\n" );
    $out = `$command`;

    $out =~ /Centre:\s+(\S+)\s+(\S+)\s+(\S+)/m;
    $x_centre = $1;
    $y_centre = $2;
    $z_centre = $3;

    $out =~ /Bounding_box:\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/m;

    $x_min = $1;
    $x_max = $2;
    $y_min = $3;
    $y_max = $4;
    $z_min = $5;
    $z_max = $6;

    return( $x_centre, $y_centre, $z_centre,
            $x_min, $x_max, $y_min, $y_max, $z_min, $z_max );
}

1;
