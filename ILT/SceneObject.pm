#!/usr/local/bin/perl5 -w

    package  ILT::SceneObject;

    use      strict;
    use      ILT::LayoutUtils;
    use      ILT::ProgUtils;

my( $this_class ) = "ILT::SceneObject";

sub new( $ )
{
    my( $proto ) = arg_any( shift );
    end_args( @_ );

    my $class = ref($proto) || $proto;
    my $self  = {};

    bless ($self, $class);
    return $self;
}

sub  create_temp_geometry_file( $ )
{
    my( $self )   = arg_object( shift, $this_class );
    end_args( @_ );

#--- nothing to do for base class
}

sub  delete_temp_geometry_file()
{
    my( $self )   = arg_object( shift, $this_class );
    end_args( @_ );

#--- nothing to do for base class
}

sub  make_ray_trace_args()
{
    my( $self )   = arg_object( shift, $this_class );
    end_args( @_ );

    fatal_error( "called make_ray_trace_args() for base class\n" );
}

sub  get_plane_intersection( $$$$ )
{
    my( $self )              = arg_object( shift, $this_class );
    my( $plane_origin_ref )  = arg_array_ref( shift, 3 );
    my( $plane_normal_ref )  = arg_array_ref( shift, 3 );
    my( $output_file )       = arg_string( shift );
    end_args( @_ );

    fatal_error( "called get_plane_intersection() for base class\n" );
}

sub  compute_bounding_view( $$$$ )
{
    my( $self )                = arg_object( shift, $this_class );
    my( $view_direction_ref )  =  arg_array_ref( shift, 3 );
    my( $up_direction_ref )    =  arg_array_ref( shift, 3 );
    my( $transform )           =  arg_string( shift );
    end_args( @_ );

    fatal_error( "called compute_bounding_view() for base class\n" );
}

sub  get_default_view( $ )
{
    my( $self )                = arg_object( shift, $this_class );
    end_args( @_ );

    fatal_error( "called get_default_view() for base class\n" );
}

sub DESTROY()
{
    my( $self )                = arg_object( shift, $this_class );
    end_args( @_ );

    $self->delete_temp_geometry_file();
}

1;
