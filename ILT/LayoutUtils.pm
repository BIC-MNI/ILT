#!/usr/local/bin/perl5 -w

    package  ILT::LayoutUtils;
    use  strict;
    use  Carp;
    use UNIVERSAL qw(isa);


    BEGIN {
        use Exporter   ();
        use vars       qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

        @ISA         = qw(Exporter);
        %EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],

        # your exported package globals go here,
        # as well as any optionally exported functions

        @EXPORT_OK      = ();
        @EXPORT         = qw(
                          &end_args
                          &arg_any &arg_int &arg_real &arg_enum &arg_object
                          &arg_array_of_ints
                          &arg_array_of_reals
                          &arg_array &arg_string
                          &arg_array_ref
                          &opt_arg_int &opt_arg_real &opt_arg_enum
                          &opt_arg_object &opt_arg_string
                          &opt_arg_array_of_reals
                          &get_tmp_file &delete_tmp_files &system_call
                          &compute_geometry_file_bounding_view
                          &clean_up &clean_up_and_die
                          &add_vectors
                          &cross_vectors
                          &normalize_vector
                          &scale_vector
                          &Nearest_neighbour_interpolation
                          &Linear_interpolation
                          &Cubic_interpolation
                          &N_interpolation_enums
                          &Flat_shading
                          &Smooth_shading
                          &N_shading_enums
                          &Gray_scale
                          &Hot_metal_scale
                          &Spectral_scale
                          &Red_scale
                          &Green_scale
                          &Blue_scale
                          &Over_colour_scale
                          &Usercc_scale
                          &N_colour_coding_enums
                          &Sagittal_axis
                          &Coronal_axis
                          &Transverse_axis
                          &N_axis_enums
                          &Left_view
                          &Right_view
                          &Top_view
                          &Bottom_view
                          &Back_view
                          &Front_view
                          &N_view_enums
                          &False
                          &True
                          &N_boolean_enums
                          &min
                          &max
                          &error
                          &warning
                          &fatal_error
                        );
    }

#---------------------------  error function

sub  error( @ )
{
    my( @args ) = @_;

    print( "Error: ", @args, "\n" );
}

sub  warning( @ )
{
    my( @args ) = @_;

    print( "Warning: ", @args, "\n" );
}

sub  fatal_error( @ )
{
    my( @args ) = @_;

    error( @args );
    clean_up_and_die();
}

#---------------------------  Perl argument checking

sub  is_scalar( $ )
{
    my( $s ) = @_;

    return( !ref($s) );
}

sub  is_numeric( $ )
{
    my( $number ) = @_;

    return( 1 );       #--- insert numeric test here
}

sub  is_int( $ )
{
    my( $i ) = @_;

    return( is_numeric($i) && int($i) == $i );
}

sub  arg_object( $$ )
{
    my( $obj, $expected_class ) = @_;

    if( !isa( $obj, $expected_class ) )
    {
        fatal_error(
           "Expected an object argument of class: $expected_class\n" );
    }

    return( $obj );
}

sub  arg_enum( $$ )
{
    my( $value, $n_enum ) = @_;

    if( !defined($value) )
        { fatal_error( "Expected an argument, but got <undef>\n" ); }

    if( !is_scalar( $value ) || $value < 0 || $value >= $n_enum ||
        !is_int( $value ) )
    {
        fatal_error( "Expected an enum, but got <$value>\n" );
    }

    return( $value );
}

sub  arg_int( $@ )
{
    my( $value, $min_value, $max_value ) = @_;

    if( !defined($value) )
        { fatal_error( "Expected an argument, but got <undef>\n" ); }

    if( !is_scalar( $value ) || !is_int($value) )
        { fatal_error( "Expected an integer, but got <$value>\n" ); }

    if( defined($min_value) && !defined($max_value) && $value < $min_value )
    {
        fatal_error( "Expected an int in the range > $min_value, " .
               "but got a value of $value\n" );
    }

    if( defined($min_value) && defined($max_value) &&
        ($value < $min_value || $value > $max_value) )
    {
        fatal_error(
               "Expected an integer in the range $min_value to $max_value, " .
               "but got a value of $value\n" );
    }

    return( $value );
}

sub  arg_real( $@ )
{
    my( $value, $min_value, $max_value ) = @_;

    if( !defined($value) )
        { fatal_error( "Expected an argument, but got <undef>\n" ); }

    if( !is_scalar($value) || !is_numeric($value) )
        { fatal_error( "Expected a real, but got a non-scalar <$value>\n" ); }

    if( defined($min_value) && !defined($max_value) && $value < $min_value )
    {
        fatal_error( "Expected a real in the range > $min_value, " .
               "but got a value of $value\n" );
    }

    if( defined($min_value) && defined($max_value) &&
        ($value < $min_value || $value > $max_value) )
    {
        fatal_error( "Expected a real in the range $min_value to $max_value, " .
               "but got a value of $value\n" );
    }

    return( $value );
}

sub  arg_any( $ )
{
    my( $value ) = @_;

    if( !defined($value) )
        { fatal_error( "Expected an argument, but got <undef>\n" ); }

    return( $value );
}

sub  arg_string( $ )
{
    my( $value ) = @_;

    if( !defined($value) )
        { fatal_error( "Expected an argument, but got <undef>\n" ); }

    if( !is_scalar($value) )
        { fatal_error( "Expected a string, but got a non-scalar <$value>\n" ); }

    return( $value );
}

sub  opt_arg_int( $@ )
{
    my( $value ) = @_;

    if( !defined($value) )
        { return( $value ); }
    else
        { return( arg_int( @_ ) ); }
}

sub  opt_arg_real( $@ )
{
    my( $value, @remaining ) = @_;

    if( !defined($value) )
        { return( $value ); }
    else
        { return( arg_real( $value, @remaining ) ); }
}

sub  opt_arg_string( $@ )
{
    my( $value ) = @_;

    if( !defined($value) )
        { return( $value ); }
    else
        { return( arg_string( $value ) ); }
}

sub  opt_arg_enum( $@ )
{
    my( $value, $max_enum ) = @_;

    if( !defined($value) )
        { return( $value ); }
    else
        { return( arg_enum( $value, $max_enum ) ); }
}

sub  opt_arg_object( $$ )
{
    my( $value, $class ) = @_;

    if( !defined($value) )
        { return( $value ); }
    else
        { return( arg_object( $value, $class ) ); }
}

sub  arg_array_of_reals( $@ )
{
    my( $arg_ref, $n ) = @_;

    my( @list, $count, $arg );

    if( ref($arg_ref) ne "ARRAY" )
        { fatal_error( "arg_array_of_reals() first argument should be \@_" ); }

    @list = ();

    $count = 0;
    while( defined($arg = shift(@$arg_ref)) && (!defined($n) || $count < $n) )
    {
        push( @list, arg_real($arg) );
        ++$count;
    }

    if( defined($n) && $count != $n )
    {
        { fatal_error( "arg_array_of_reals() incorrect number of args.\n" ); }
    }

    return( @list );
}

sub  opt_arg_array_of_reals( $@ )
{
    my( $arg_ref, $n ) = @_;

    if( @$arg_ref == 0 )
        { return(); }
    else
        { return( arg_array_of_reals( $arg_ref, $n ) ); }
}

sub  arg_array_of_ints( $@ )
{
    my( $arg_ref, $n ) = @_;

    my( @list, $count, $arg );

    if( ref($arg_ref) ne "ARRAY" )
        { fatal_error( "arg_list_of_ints() first argument should be \@_" ); }

    $count = 0;
    while( defined($arg = shift(@$arg_ref)) && (!defined($n) || $count < $n) )
    {
        push( @list, arg_int($arg) );
        ++$count;
    }

    if( defined($n) && $count != $n )
    {
        { fatal_error( "arg_array_of_ints() incorrect number of args.\n" ); }
    }

    return( @list );
}

sub  arg_array( $@ )
{
    my( $arg_ref, $n ) = @_;

    my( $arg, @list, $count );

    if( ref($arg_ref) ne "ARRAY" )
        { fatal_error( "arg_list_of_ints() first argument should be \@_" ); }

    $count = 0;

    while( defined($n) && $count < $n || !defined($n) && @{$arg_ref} )
    {
        $arg = shift( @$arg_ref );

        push( @list, $arg );
    }

    if( defined( $n ) && $count != $n )
        { fatal_error( "Expected $n args for arg_array()" ); }

    return( @list );
}

sub  arg_array_ref( $@ )
{
    my( $value, $n_elements ) = @_;

    if( ref($value) ne "ARRAY" )
        { fatal_error( "Expected an array ref, but got <$value>\n" ); }

    if( defined($n_elements) && @$value != $n_elements )
    {
        my( $size ) = @$value;
        fatal_error( "Expected an array of size $n_elements, but got $size\n" );
    }

    return( $value );
}

sub  end_args( @ )
{
    my( @args ) = @_;

    if( @args )
    {
        fatal_error(
             "Found extra arguments to a function call: <", qw(@args), ">\n");
    }
}

#--------------------------

sub  get_filename_base( $ )
{
    my( $file ) = arg_string( shift );
    end_args( @_ );

    $file =~ s/.*\///;
    $file =~ s/\..*//;

    return( $file );
}

sub  get_prefix( $ )
{
    my( $file ) = arg_string( shift );
    end_args( @_ );

    $file =~ s/\.[^\.]*$//;   

    return( $file );
}

sub  copy_file( $$ )
{
    my( $src ) = arg_string( shift );
    my( $dest ) = arg_string( shift );
    end_args( @_ );

    system_call( "cp $src $dest" );
}

sub get_directory( $ )
{
    my( $filename ) = arg_string( shift );
    end_args( @_ );

    my( $dir );

    $dir = $filename;

    $dir =~ s/[^\/]*$//;

    if( ! $dir )  { $dir = "."; }

    if( substr( $dir, -1, 1 ) ne "/" )
        { $dir = $dir . "/"; }

    return( $dir );
}

sub get_filename_no_dirs( $ )
{
    my( $filename ) = arg_string( shift );
    end_args( @_ );

    my( $no_dirs );

    $no_dirs = $filename;

    $no_dirs =~ s/.*\///;

    if( ! $no_dirs )  { $no_dirs = "."; }

    return( $no_dirs );
}

#--------------- tmp files -------------------

my $initialized = 0;

my %all_tmp_files;

sub  register_tmp_files( @ )
{
    my( @args ) = @_;
    my $arg;

    if( ! $initialized )
    {
        $initialized = 1;
        $SIG{INT} = 'catch_interrupt_and_delete_tmp';
        $SIG{QUIT} = 'catch_interrupt_and_delete_tmp';
        $SIG{ABRT} = 'catch_interrupt_and_delete_tmp';
        $SIG{KILL} = 'catch_interrupt_and_delete_tmp';
        $SIG{SEGV} = 'catch_interrupt_and_delete_tmp';
        $SIG{STOP} = 'catch_interrupt_and_delete_tmp';
        $SIG{TERM} = 'catch_interrupt_and_delete_tmp';
    }

    foreach $arg ( @args )
    {
        $all_tmp_files{$arg} = 1;
    }
}

sub  unregister_tmp_files( @ )
{
    my( @args ) = @_;
    my $arg;

    foreach $arg ( @args )
    {
        delete( $all_tmp_files{$arg} );
    }
}

sub  delete_tmp_files( @ )
{
    my @args = @_;
    my $arg;

    foreach $arg ( @args )
    {
        if( -e "$arg" ) { unlink( $arg ) }
    }

    unregister_tmp_files( @args );
}

sub  clean_up()
{
    delete_tmp_files( keys(%all_tmp_files) );
}

sub  clean_up_and_die( @ )
{
    clean_up();
    confess( @_ , "\n" );
}

sub catch_interrupt_and_delete_tmp( $ )
{
    my( $signame ) = arg_string( shift );
    end_args( @_ );

    clean_up_and_die( "Received SIG$signame\n" );
}

my $tmp_file_index = 0;

sub get_tmp_file( $ )
{
    my( $suffix ) = arg_string( shift );
    end_args( @_ );

    my $tmp_file;

    if( defined($suffix) )
        { $suffix = "." . $suffix; }
    else
        { $suffix = ""; }

    $tmp_file = "/tmp/tmp_${$}_${tmp_file_index}${suffix}";

    register_tmp_files( $tmp_file );

    ++$tmp_file_index;

    return( $tmp_file );
}

#-------------------------

sub system_call( $ )
{
    my( $command ) = arg_string( shift );
    end_args( @_ );

    my( $ret, @separate, $com );

    print( "$command\n" );
    $ret = system( $command );
    if( $ret != 0 )
    {
        @separate = split( /\s+/, $command );
        $com = $separate[0];
        if( $ret == 2 )
            { clean_up_and_die( "System command <$com> was interrupted.\n" ); }
        elsif( $ret == 65280 )
            { clean_up_and_die( "System command <$com> was not found.\n" ); }
        else
            { clean_up_and_die( "System command <$com> failed with return value
 <$ret>.\n" ); }
    }
    return( $ret / 256 );
}

#---------------

sub compute_geometry_file_bounding_view( $$$@ )
{
    my( $filename )           = arg_string( shift );
    my( $view_direction_ref ) = arg_array_ref( shift, 3 );
    my( $up_direction_ref )   = arg_array_ref( shift, 3 );
    my( $transform )          = arg_string( shift );
    end_args( @_ );

    my( @view_direction, @up_direction, $command,
        $x_centre, $y_centre, $z_centre, $out,
        $x_min, $x_max, $y_min, $y_max, $z_min, $z_max );

    @view_direction = @$view_direction_ref;
    @up_direction = @$up_direction_ref;

    if( !defined($transform) )
        { $transform = ""; }

    $command = sprintf( "compute_bounding_view %s %g %g %g %g %g %g %s",
                        $filename,
                        $view_direction[0],
                        $view_direction[1],
                        $view_direction[2],
                        $up_direction[0],
                        $up_direction[1],
                        $up_direction[2],
                        $transform );

    $out = `$command`;

    $out =~ /Bounding_box:\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/m;

    $x_min = $1;
    $x_max = $2;
    $y_min = $3;
    $y_max = $4;
    $z_min = $5;
    $z_max = $6;

    return( $x_min, $x_max, $y_min, $y_max, $z_min, $z_max );
}

#------ Enumerated types for interpolation methods

sub Nearest_neighbour_interpolation() { return( 0 ); }
sub Linear_interpolation()            { return( 1 ); }
sub Cubic_interpolation()             { return( 2 ); }
sub N_interpolation_enums()           { return( 3 ); }

#------ Enumerated types for interpolation methods

sub Flat_shading()                    { return( 0 ); }
sub Smooth_shading()                  { return( 1 ); }
sub N_shading_enums()                 { return( 2 ); }

#----- Enumerated types for colour coding methods

sub Gray_scale()               { return( 0 ); }
sub Hot_metal_scale()          { return( 1 ); }
sub Spectral_scale()           { return( 2 ); }
sub Red_scale()                { return( 3 ); }
sub Green_scale()              { return( 4 ); }
sub Blue_scale()               { return( 5 ); }
sub Over_colour_scale()        { return( 6 ); }
sub Usercc_scale()             { return( 7 ); }
sub N_colour_coding_enums()    { return( 8 ); }

#----- Enumerated types for views

sub Left_view()       { return( 0 ); }
sub Right_view()      { return( 1 ); }
sub Top_view()        { return( 2 ); }
sub Bottom_view()     { return( 3 ); }
sub Back_view()       { return( 4 ); }
sub Front_view()      { return( 5 ); }
sub N_view_enums()    { return( 6 ); }

#----- Enumerated types for axes

sub Sagittal_axis()       { return( 0 ); }
sub Coronal_axis()        { return( 1 ); }
sub Transverse_axis()     { return( 2 ); }
sub N_axis_enums()        { return( 3 ); }

#---------- vector operations

sub add_vectors( $$ )
{
    my( $v1 ) = arg_array_ref( shift, 3 );
    my( $v2 ) = arg_array_ref( shift, 3 );
    end_args( @_ );

    return( $$v1[0] + $$v2[0], $$v1[1] + $$v2[1], $$v1[2] + $$v2[2] );
}

sub cross_vectors( $$ )
{
    my( $v1 ) = arg_array_ref( shift, 3 );
    my( $v2 ) = arg_array_ref( shift, 3 );
    end_args( @_ );

    return( $$v1[1] * $$v2[2] - $$v1[2] * $$v2[1],
            $$v1[2] * $$v2[0] - $$v1[0] * $$v2[2],
            $$v1[0] * $$v2[1] - $$v1[1] * $$v2[0] );
}

sub scale_vector( $@ )
{
    my( $scale ) = arg_real( shift );
    my( $x )     = arg_real( shift );
    my( $y )     = arg_real( shift );
    my( $z )     = arg_real( shift );
    end_args( @_ );
 
    return( $scale * $x, $scale * $y, $scale * $z );
}

sub normalize_vector( @ )
{
    my( $x )     = arg_real( shift );
    my( $y )     = arg_real( shift );
    my( $z )     = arg_real( shift );
    end_args( @_ );

    my( $length );
 
    $length = $x * $x + $y * $y + $z * $z;
    $length = sqrt( $length );

    return( scale_vector( 1/$length, $x, $y, $z ) );
}

#----- Boolean enums

sub  False { return( 0 ); }
sub  True  { return( 1 ); }
sub  N_boolean_enums  { return( 2 ); }

#----- min and max

sub  min( @ )
{
    my( @args ) = arg_array_of_reals( \@_ );
    end_args( @_ );

    my( $arg, $min );

    $min = undef;

    foreach $arg ( @args )
    {
        if( !defined($min) || $arg < $min )
            { $min = $arg; }
    }

    return( $min );
}

sub  max( @ )
{
    my( @args ) = arg_array_of_reals( \@_ );
    end_args( @_ );

    my( $arg, $max );

    $max = undef;

    foreach $arg ( @args )
    {
        if( !defined($max) || $arg > $max )
            { $max = $arg; }
    }

    return( $max );
}

#---------------- return value for 'use'

1;

