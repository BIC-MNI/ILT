#!/usr/local/bin/perl5 -w

    package  ILT::ImageLayout;

    use      strict;
    use      ILT::LayoutUtils;
    use      ILT::LayoutInclude;

my( $this_class ) = "ILT::ImageLayout";

sub new( $ )
{
    my( $proto )  = shift;
    end_args( @_ );

    my $class = ref($proto) || $proto;
    my $self  = {};

    bless ($self, $class);

    $self->n_images( 0 );
    $self->{N_ROWS} = 0;
    $self->{N_COLS} = 0;
    $self->{IMAGES} = [];
    $self->horizontal_white_space( 0 );
    $self->vertical_white_space( 0 );
    $self->white_space_colour( "black" );

    return $self;
}

sub new_grid( $$$ )
{
    my( $proto )  = shift;
    my( $n_rows ) = arg_int( shift, 1, 1e30 );
    my( $n_cols ) = arg_int( shift, 1, 1e30 );
    end_args( @_ );

    my( $self );

    $self = new ILT::ImageLayout;

    $self->{N_ROWS} = $n_rows;
    $self->{N_COLS} = $n_cols;
    $self->{N_IMAGES} = $n_rows * $n_cols;

    return $self;
}

sub n_images( $@ )
{
    my( $self )     = arg_object( shift, $this_class );
    my( $n_images ) = opt_arg_int( shift, 1, 1e30 );
    end_args( @_ );

    if( defined( $n_images ) )
        { $self->{N_IMAGES} = $n_images; }

    return( $self->{N_IMAGES} );
}

sub n_rows( $ )
{
    my( $self ) = arg_object( shift, $this_class );
    end_args( @_ );

    return( $self->{N_ROWS} );
}

sub n_cols( $ )
{
    my( $self ) = arg_object( shift, $this_class );
    end_args( @_ );

    return( $self->{N_COLS} );
}

sub horizontal_white_space( $@ )
{
    my( $self )     = arg_object( shift, $this_class );
    my( $horizontal_white_space ) = opt_arg_real( shift, 0.0, 1e30 );
    end_args( @_ );

    if( defined( $horizontal_white_space ) )
        { $self->{HORIZONTAL_WHITE_SPACE} = $horizontal_white_space; }

    return( $self->{HORIZONTAL_WHITE_SPACE} );
}

sub vertical_white_space( $@ )
{
    my( $self )     = arg_object( shift, $this_class );
    my( $vertical_white_space ) = opt_arg_real( shift, 0.0, 1e30 );
    end_args( @_ );

    if( defined( $vertical_white_space ) )
        { $self->{VERTICAL_WHITE_SPACE} = $vertical_white_space; }

    return( $self->{VERTICAL_WHITE_SPACE} );
}

sub white_space_colour( $@ )
{
    my( $self )     = arg_object( shift, $this_class );
    my( $white_space_colour ) = opt_arg_string( shift );
    end_args( @_ );

    if( defined( $white_space_colour ) )
        { $self->{WHITE_SPACE_COLOUR} = $white_space_colour; }

    return( $self->{WHITE_SPACE_COLOUR} );
}

sub  is_in_grid_mode( $ )
{
    my( $self )     = arg_object( shift, $this_class );
    end_args( @_ );

    return( $self->n_rows() > 0 && $self->n_cols() > 0 );
}

sub  row_col_to_index( $$$ )
{
    my( $self )    = arg_object( shift, $this_class );
    my( $row )     = arg_int( shift, 0, $self->n_rows()-1 );
    my( $col )     = arg_int( shift, 0, $self->n_cols()-1 );
    end_args( @_ );

    return( $row * $self->{N_COLS} + ($self->{N_COLS}-1-$col) );
}

sub image_info( $$@ )
{
    my( $self )         = arg_object( shift, $this_class );
    my( $image_index )  = arg_int( shift, 0, $self->n_images()-1 );
    my( $value_to_set ) = opt_arg_object( shift, "ILT::ImageInfo" );
    end_args( @_ );

    if( defined( $value_to_set ) )
    {
        $self->{IMAGES}[$image_index] = $value_to_set;
    }

    return( $self->{IMAGES}[$image_index] );
}

sub   compute_geometry( $$$$$$$ )
{
    my( $self       )    = arg_object( shift, $this_class );
    my( $full_x_size )   = arg_int( shift, 1, 1e30 );
    my( $full_y_size )   = arg_int( shift, 1, 1e30 );
    my( $x_pos )         = arg_array_ref( shift );
    my( $y_pos )         = arg_array_ref( shift );
    my( $x_sizes )       = arg_array_ref( shift );
    my( $y_sizes )       = arg_array_ref( shift );
    end_args( @_ );

    my( $x_size, $y_size, $row, $col, $n_rows, $n_cols, $image_index,
        $hor_white_space, $vert_white_space,
        $width, $height, @max_world_height, @max_world_width,
        $total_height, $total_width, $x_scale, $y_scale, $scale,
        $x_offset, $y_offset, $current_x, $current_y );

    if( $self->is_in_grid_mode() )
    {
        $hor_white_space = $self->horizontal_white_space();
        $vert_white_space = $self->vertical_white_space();
        $n_rows = $self->n_rows();
        $n_cols = $self->n_cols();
        $x_size = $full_x_size - ($n_cols - 1) * $hor_white_space;
        $y_size = $full_y_size - ($n_rows - 1) * $vert_white_space;

        for( $row = 0;  $row < $n_rows;  ++$row )
        {
            $max_world_height[$row] = 0;
        }

        for( $col = 0;  $col < $n_cols;  ++$col )
        {
            $max_world_width[$col] = 0;
        }

        for( $row = 0;  $row < $n_rows;  ++$row )
        {
            for( $col = 0;  $col < $n_cols;  ++$col )
            {
                $image_index = $self->row_col_to_index( $row, $col );

                if( $self->{IMAGES}[$image_index]->scene_view()->
                                                get_bounding_box_width() >
                    $max_world_width[$col] )
                {
                    $max_world_width[$col] =
                           $self->{IMAGES}[$image_index]->scene_view()->
                                               get_bounding_box_width();
                }

                if( $self->{IMAGES}[$image_index]->scene_view()->
                                                 get_bounding_box_height() >
                    $max_world_height[$row] )
                {
                    $max_world_height[$row] =
                           $self->{IMAGES}[$image_index]->scene_view()->
                                                 get_bounding_box_height();
                }
            }
        }

        $total_height = 0;
        for( $row = 0;  $row < $n_rows;  ++$row )
            { $total_height += $max_world_height[$row]; }

        $total_width = 0;
        for( $col = 0;  $col < $n_cols;  ++$col )
            { $total_width += $max_world_width[$col]; }

        $x_scale = $x_size / $total_width;
        $y_scale = $y_size / $total_height;

        if( $x_scale < $y_scale )
            { $scale = $x_scale; }
        else
            { $scale = $y_scale; }

        $x_offset = ($full_x_size - $scale * $total_width -
                      ($n_cols-1) * $hor_white_space) / 2;
        $y_offset = ($full_y_size - $scale * $total_height -
                      ($n_rows-1) * $vert_white_space) / 2;

        $current_y = $y_offset;
        for( $row = 0;  $row < $n_rows;  ++$row )
        {
            $height = $scale * $max_world_height[$row];
            $current_x = $x_offset;
            for( $col = 0;  $col < $n_cols;  ++$col )
            {
                $width = $scale * $max_world_width[$col];

                $image_index = $self->row_col_to_index( $row, $col );

                $$x_sizes[$image_index] = int( $scale *
                             $self->{IMAGES}[$image_index]->scene_view()->
                                       get_bounding_box_width() ) - 1;
                $$x_pos[$image_index] = $current_x +
                              ($width - $$x_sizes[$image_index]) / 2;

                $$y_sizes[$image_index] = int( $scale *
                             $self->{IMAGES}[$image_index]->scene_view()->
                                 get_bounding_box_height() ) - 1;
                $$y_pos[$image_index] = $current_y +
                              ($height - $$y_sizes[$image_index]) / 2;

                $current_x += $width + $hor_white_space;
            }

            $current_y += $height + $vert_white_space;
        }
    }
    else
    {
        fatal_error( "compute_geometry():  not implemented yet\n" );
    }
}

sub generate_image
{
    my( $self     )    = arg_object( shift, $this_class );
    my( $filename )    = arg_string( shift );
    my( $full_x_size ) = arg_int( shift, 1, 1e30 );
    my( $full_y_size ) = arg_int( shift, 1, 1e30 );
    end_args( @_ );

    my( $image_index, @x_pos, @y_pos, @x_size, @y_size,
        @tmp_image_files, $white_space_colour, $layout_args );

    for( $image_index = 0;  $image_index < $self->{N_IMAGES};  ++$image_index )
    {
        $self->{IMAGES}[$image_index]->scene_view()->
                        compute_view_for_object(
                                $self->{IMAGES}[$image_index]->scene_object );
    }

    $self->compute_geometry( $full_x_size, $full_y_size,
                             \@x_pos, \@y_pos, \@x_size, \@y_size );

    @tmp_image_files = ();

    $layout_args = "";

    for( $image_index = 0;  $image_index < $self->{N_IMAGES};  ++$image_index )
    {
        $tmp_image_files[$image_index] = get_tmp_file( "rgb" );

        $self->{IMAGES}[$image_index]->create_image(
                    $tmp_image_files[$image_index],
                    $x_size[$image_index],
                    $y_size[$image_index],
                    $self->{IMAGES}[$image_index]->scene_view() );

        $self->{IMAGES}[$image_index]->scene_object()->delete_temp_geometry_file();

        $layout_args = $layout_args . " " . $tmp_image_files[$image_index] .
                       " " . $x_pos[$image_index] .
                       " " . $y_pos[$image_index];
    }

    $white_space_colour = $self->{WHITE_SPACE_COLOUR};

    system_call( "place_images $filename $white_space_colour " .
                 " -size $full_x_size $full_y_size $layout_args" );

    delete_tmp_files( @tmp_image_files );
}

1;
