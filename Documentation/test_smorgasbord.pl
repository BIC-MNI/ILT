#!/usr/local/bin/perl5 -w

#-------------------------------------------------------
#
#  This script configures an image of M volumes by N slices
#  using the ImageLayout object and related objects.  As such,
#  it is simply a demonstration of the interface to the ImageLayout object
#
#  Author: David MacDonald        March, 1998
#
#--------------------------------------------------------

    use LayoutInclude;
    use Utils;

#-------------------------------------------------------
#
#  Define the information to be displayed
#
#  This could be done in any number of ways, so the simplest is shown here
#  for demonstration purposes
#
#--------------------------------------------------------

    $n_rows = 3;
    $n_cols = 4;
    $layout = ImageLayout->new( $n_rows, $n_cols );

    $layout->output_filename( "output.rgb" );

    $layout->output_size( 600, 600 );
    $layout->horizontal_white_space( 10 );
    $layout->vertical_white_space( 8 );
    $layout->white_space_colour( "dim_gray" );

    for( $row = 0;  $row < $n_rows;  ++$row )
    {
        for( $col = 0;  $col < $n_cols;  ++$col )
        {
            $view = View->new( "top" );
            $surface_object = GeometricObject->new( "Data/surf1.obj" );
            $image_info = ImageInfo->new( $surface_object, $view );
            $layout->image_info( $row, $col, $image_info );
        }
    }

#--------------------------------------------------------------------------
#
#   image[0][0] is an x-slice through volume without any colour coding
#
#--------------------------------------------------------------------------

    $plane_object = PlaneObject->new( "x", -10 );
    $view = View->new( "left" );
    $volume_object = VolumeObject->new( "Data/volume1.mnc" );
    $scene_object = IntersectionObject->new( $plane_object, $volume_object );
    $image_info = ImageInfo->new( $scene_object, $view );
    $layout->image_info( 0, 0, $image_info );

#--------------------------------------------------------------------------
#
#   image[0][1] is an x-slice through a volume with colour coding
#
#--------------------------------------------------------------------------

    $plane_object = PlaneObject->new( "x", -10 );
    $view = View->new( "left" );
    $volume_object = VolumeObject->new( "Data/volume1.mnc" );

    $scene_object = 
                  ColourObject->new(
                       IntersectionObject->new( $plane_object,
                                                $volume_object ),
                       $volume_object, Hot_metal_scale, 50, 150 );

    $image_info = ImageInfo->new( $scene_object, $view );
    $layout->image_info( 0, 1, $image_info );

#--------------------------------------------------------------------------
#
#   image[0][2] is three colour-coded slices with a three-d view
#
#--------------------------------------------------------------------------

    $plane_object1 = PlaneObject->new( "x", 0 );
    $plane_object2 = PlaneObject->new( "y", 0 );
    $plane_object3 = PlaneObject->new( "z", 0 );
    $view = View->new( -1, -2, -1, 0, 0, 1 );
    $volume_object = VolumeObject->new( "Data/volume1.mnc" );

    $coloured_slice1 = ColourObject->new(
                           IntersectionObject->new( $plane_object1,
                                                    $volume_object ),
                           $volume_object, Hot_metal_scale, 50, 150 );
    $coloured_slice2 = ColourObject->new(
                           IntersectionObject->new( $plane_object2,
                                                    $volume_object ),
                           $volume_object, Hot_metal_scale, 50, 150 );
    $coloured_slice3 = ColourObject->new(
                           IntersectionObject->new( $plane_object3,
                                                    $volume_object ),
                           $volume_object, Hot_metal_scale, 50, 150 );

    $union = UnionObject->new( $coloured_slice1,
                               $coloured_slice2,
                               $coloured_slice3 );

    $scene_object = RenderObject->new( $union );
    $scene_object->lighting_state( True );

    $image_info = ImageInfo->new( $scene_object, $view );
    $layout->image_info( 0, 2, $image_info );

#--------------------------------------------------------------------------
#
#   image[0][3] is an x-slice through a PET volume overlaid on average MRI
#
#--------------------------------------------------------------------------

    $plane_object = PlaneObject->new( "x", -10 );
    $view = View->new( "left" );
    $mri_volume = VolumeObject->new( "Data/volume1.mnc" );
    $pet_volume = VolumeObject->new(
           "/avgbrain/brain/images/mni_demo_fdg_normal_pet_tal.mnc.gz" );
    $slice_object = IntersectionObject->new( $plane_object,
                                             $mri_volume ),


    $coloured_mri = ColourObject->new( $slice_object,
                           $mri_volume, Gray_scale, 50, 150 );

    $scene_object = ColourObject->new( $coloured_mri,
                                       $pet_volume, Spectral_scale, 400, 500 );
    $scene_object->under_colour( "transparent" );
    $scene_object->opacity( .5 );

    $image_info = ImageInfo->new( $scene_object, $view );
    $layout->image_info( 0, 3, $image_info );

#--------------------------------------------------------------------------
#
#   image[1][0] is a right view of a lit surface
#
#--------------------------------------------------------------------------

    $surface_object = GeometricObject->new( "Data/surf2.obj" );
    $view = View->new( "right" );

    $scene_object = RenderObject->new( $surface_object );
    $scene_object->lighting_state( True );

    $image_info = ImageInfo->new( $scene_object, $view );
    $layout->image_info( 1, 0, $image_info );

#--------------------------------------------------------------------------
#
#   image[1][1] is a cross section of a surface
#
#--------------------------------------------------------------------------

    $plane_object = PlaneObject->new( "x", -40 );
    $surface_object = GeometricObject->new( "Data/surf2.obj" );
    $view = View->new( "right" );

    $cross = IntersectionObject->new( $plane_object, $surface_object ),
    $scene_object = $cross;

    $image_info = ImageInfo->new( $scene_object, $view );
    $layout->image_info( 1, 1, $image_info );

#--------------------------------------------------------------------------
#
#   image[1][2] is a cross section of a surface superimposed on a colour_coded
#               slice
#
#--------------------------------------------------------------------------

    $plane_object = PlaneObject->new( "x", -40 );
    $surface_object = GeometricObject->new( "Data/surf2.obj" );
    $volume_object = VolumeObject->new( "Data/volume1.mnc" );
    $view = View->new( "right" );

    $cross = IntersectionObject->new( $plane_object, $surface_object ),

    $coloured_slice = ColourObject->new(
                           IntersectionObject->new( $plane_object,
                                                    $volume_object ),
                           $volume_object, Gray_scale, 50, 150 );

    $scene_object = UnionObject->new( $cross, $coloured_slice );

    $image_info = ImageInfo->new( $scene_object, $view );
    $layout->image_info( 1, 2, $image_info );

#--------------------------------------------------------------------------
#
#   image[1][3] is a surface colour coded with a volume
#
#--------------------------------------------------------------------------

    $surface_object = GeometricObject->new( "Data/surf2.obj" );
    $volume_object = VolumeObject->new(
           "/avgbrain/brain/images/mni_demo_fdg_normal_pet_tal.mnc.gz" );
    $view = View->new( "left" );

    $coloured_surface = ColourObject->new( $surface_object,
                             $volume_object, Spectral_scale, 300, 350 );
    $coloured_surface->under_colour( "white" );

    $scene_object = RenderObject->new( $coloured_surface );
    $scene_object->lighting_state( True );

    $image_info = ImageInfo->new( $scene_object, $view );
    $layout->image_info( 1, 3, $image_info );

#--------------------------------------------------------------------------
#
#   image[2][0] is a set of cross sections of a surface
#
#--------------------------------------------------------------------------

    $plane_object1 = PlaneObject->new( "x", -50 );
    $plane_object2 = PlaneObject->new( "x", -25 );
    $plane_object3 = PlaneObject->new( "x", 0 );
    $plane_object4 = PlaneObject->new( "x", 25 );
    $plane_object5 = PlaneObject->new( "x", 50 );
    $surface_object = GeometricObject->new( "Data/surf2.obj" );
    $view = View->new( 1, .5, 0, 0, 0, 1 );

    $cross1 = IntersectionObject->new( $plane_object1, $surface_object ),
    $cross2 = IntersectionObject->new( $plane_object2, $surface_object ),
    $cross3 = IntersectionObject->new( $plane_object3, $surface_object ),
    $cross4 = IntersectionObject->new( $plane_object4, $surface_object ),
    $cross5 = IntersectionObject->new( $plane_object5, $surface_object ),

    $union = UnionObject->new( $cross1, $cross2, $cross3, $cross4, $cross5 );
    $render_object = RenderObject->new( $union );
    $render_object->lighting_state( True );
    $render_object->line_width( 2 );

    $image_info = ImageInfo->new( $render_object, $view );
    $layout->image_info( 2, 0, $image_info );

#--------------------------------------------------------------------------
#
#   now generate the images
#
#--------------------------------------------------------------------------

    $layout->generate_image();
