#!/usr/local/bin/perl5 -w

    package  ImageLayout;

    use      strict;
    use      ImageInfo;
    use      View;
    use      Utils;

sub new
{
    my( $proto, $arg1, $arg2 ) = @_;

    my $class = ref($proto) || $proto;
    my $self  = {};

    if( !defined( $arg1 ) )
    {
        $self->{N_ROWS} = 0;
        $self->{N_COLS} = 0;
        $self->{N_IMAGES} = 0;
    }
    elsif( !defined( $arg2 ) )
    {
        $self->{N_ROWS} = 0;
        $self->{N_COLS} = 0;
        $self->{N_IMAGES} = $arg1;
    }
    else
    {
        $self->{N_ROWS} = $arg1;
        $self->{N_COLS} = $arg2;
        $self->{N_IMAGES} = $arg1 * $arg2;
    }

    $self->{IMAGES} = [];
    $self->{HORIZONTAL_WHITE_SPACE} = 0;
    $self->{VERTICAL_WHITE_SPACE} = 0;
    $self->{WHITE_SPACE_COLOUR} = "black";

    bless ($self, $class);
    return $self;
}

sub n_images
{
    my( $self, $n_images ) = @_;

    if( defined( $n_images ) )
        { $self->{N_IMAGES} = $n_images; }

    return( $self->{N_IMAGES} );
}

sub output_filename
{
    my( $self, $output_filename ) = @_;

    if( defined( $output_filename ) )
        { $self->{OUTPUT_FILENAME} = $output_filename; }

    return( $self->{OUTPUT_FILENAME} );
}

sub output_size
{
    my( $self, $x_size, $y_size ) = @_;

    if( defined( $y_size ) )
    {
        $self->{X_SIZE} = $x_size;
        $self->{Y_SIZE} = $y_size;
    }

    return( $self->{X_SIZE}, $self->{Y_SIZE} );
}

sub horizontal_white_space
{
    my( $self, $horizontal_white_space ) = @_;

    if( defined( $horizontal_white_space ) )
        { $self->{HORIZONTAL_WHITE_SPACE} = $horizontal_white_space; }

    return( $self->{HORIZONTAL_WHITE_SPACE} );
}

sub vertical_white_space
{
    my( $self, $vertical_white_space ) = @_;

    if( defined( $vertical_white_space ) )
        { $self->{VERTICAL_WHITE_SPACE} = $vertical_white_space; }

    return( $self->{VERTICAL_WHITE_SPACE} );
}

sub white_space_colour
{
    my( $self, $white_space_colour ) = @_;

    if( defined( $white_space_colour ) )
        { $self->{WHITE_SPACE_COLOUR} = $white_space_colour; }

    return( $self->{WHITE_SPACE_COLOUR} );
}

sub  is_in_grid_mode
{
    my( $self ) = @_;

    return( $self->{N_ROWS} > 0 && $self->{N_COLS} > 0 );
}

sub  row_col_to_index
{
    my( $self, $row, $col ) = @_;

    return( $row * $self->{N_COLS} + $col );
}

sub  get_image_index_from_arguments
{
    my( $self, $args ) = @_;
    my( $row, $col, $image_index );

    if( $self->is_in_grid_mode() )
    {
        $row = shift( @$args );
        $col = shift( @$args );

        if( !defined($row) || $row < 0 || $row >= $self->{N_ROWS} ||
            !defined($col) || $col < 0 || $col >= $self->{N_COLS} )
        {
            die( "get_image_index_from_arguments() argument out of range\n" );
        }

        $image_index = $self->row_col_to_index( $row, $col );
    }
    else
    {
        $image_index = shift( @$args );

        if( !defined($image_index) ||
            $image_index < 0 || $image_index >= $self->{N_IMAGES} )
        {
            die( "get_image_index_from_arguments() argument out of range\n" );
        }
    }

    return( $image_index );
}

sub image_info
{
    my( $self ) = shift;

    my( $row, $col, $image_index, $value_to_set );

    $image_index = $self->get_image_index_from_arguments( \@_ );

    $value_to_set = shift;

    if( defined( $value_to_set ) )
    {
        $self->{IMAGES}[$image_index] = $value_to_set;
    }

    return( $self->{IMAGES}[$image_index] );
}

sub   compute_geometry
{
    my( $self, $views, $x_pos, $y_pos, $x_sizes, $y_sizes ) = @_;

    my( $x_size, $y_size, $row, $col, $n_rows, $n_cols, $image_index,
        $full_x_size, $full_y_size, $hor_white_space, $vert_white_space,
        $width, $height, @max_world_height, @max_world_width,
        $total_height, $total_width, $x_scale, $y_scale, $scale,
        $x_offset, $y_offset, $current_x, $current_y );

    $full_x_size = $self->{X_SIZE};
    $full_y_size = $self->{Y_SIZE};

    if( $self->is_in_grid_mode() )
    {
        $hor_white_space = $self->{HORIZONTAL_WHITE_SPACE};
        $vert_white_space = $self->{VERTICAL_WHITE_SPACE};
        $n_rows = $self->{N_ROWS};
        $n_cols = $self->{N_COLS};
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

                if( $$views[$image_index]->bounding_box_width >
                    $max_world_width[$col] )
                {
                    $max_world_width[$col] =
                           $$views[$image_index]->bounding_box_width;
                }

                if( $$views[$image_index]->bounding_box_height >
                    $max_world_height[$row] )
                {
                    $max_world_height[$row] =
                           $$views[$image_index]->bounding_box_height;
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
                             $$views[$image_index]->bounding_box_width ) - 1;
                $$x_pos[$image_index] = $current_x +
                              ($width - $$x_sizes[$image_index]) / 2;

                $$y_sizes[$image_index] = int( $scale *
                             $$views[$image_index]->bounding_box_height ) - 1;
                $$y_pos[$image_index] = $current_y +
                              ($height - $$y_sizes[$image_index]) / 2;

                $current_x += $width + $hor_white_space;
            }

            $current_y += $height + $vert_white_space;
        }
    }
    else
    {
        die( "compute_geometry():  not implemented yet\n" );
    }
}

sub generate_image
{
    my( $self ) = @_;

    my( $image_index, @x_pos, @y_pos, @x_size, @y_size, @views,
        @tmp_image_files, $filename, $white_space_colour, $layout_args );

    $filename = $self->{OUTPUT_FILENAME};
    if( !defined( $filename ) )
        { die( "No output filename specified in ImageLayout\n" ); }

    for( $image_index = 0;  $image_index < $self->{N_IMAGES};  ++$image_index )
    {
        $views[$image_index] = View->compute_view(
                                  $self->{IMAGES}[$image_index]->scene_view(),
                                  $self->{IMAGES}[$image_index]->scene_object );
    }

    $self->compute_geometry( \@views, \@x_pos, \@y_pos, \@x_size, \@y_size );

    @tmp_image_files = ();

    $layout_args = "";

    for( $image_index = 0;  $image_index < $self->{N_IMAGES};  ++$image_index )
    {
        $tmp_image_files[$image_index] = get_tmp_file( "rgb" );

        $self->{IMAGES}[$image_index]->create_image(
                    $tmp_image_files[$image_index],
                    $x_size[$image_index],
                    $y_size[$image_index],
                    $views[$image_index] );

        $layout_args = $layout_args . " " . $tmp_image_files[$image_index] .
                       " " . $x_pos[$image_index] .
                       " " . $y_pos[$image_index];
    }

    $white_space_colour = $self->{WHITE_SPACE_COLOUR};

    system_call( "place_images $filename $white_space_colour $layout_args" );

    delete_tmp_files( @tmp_image_files );
}

1;
