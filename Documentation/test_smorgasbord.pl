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

    use ILT::LayoutInclude;
    use ILT::LayoutUtils;

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
    $layout = ILT::ImageLayout->new_grid( $n_rows, $n_cols );

    $layout->horizontal_white_space( 3 );
    $layout->vertical_white_space( 3 );
    $layout->white_space_colour( "dim_gray" );

    for( $row = 0;  $row < $n_rows;  ++$row )
    {
        for( $col = 0;  $col < $n_cols;  ++$col )
        {
            $view = ILT::View->new_canonical( Top_view );
            $surface_object = ILT::GeometricObject->new( "Data/surf1.obj" );
            $image_info = ILT::ImageInfo->new( $surface_object, $view );
            $layout->image_info( $layout->row_col_to_index($row,$col),
                                 $image_info );
        }
    }

#--------------------------------------------------------------------------
#
#   image[0][0] is an x-slice through volume without any colour coding
#
#--------------------------------------------------------------------------

    $plane_object = ILT::PlaneObject->new_canonical( Sagittal_axis, -10 );
    $view = ILT::View->new_canonical( Left_view );
    $volume_object = ILT::VolumeObject->new( "Data/volume1.mnc" );
    $scene_object = ILT::IntersectionObject->new( $plane_object,
                                                  $volume_object );
    $image_info = ILT::ImageInfo->new( $scene_object, $view );
    $layout->image_info( $layout->row_col_to_index(0,0), $image_info );

#--------------------------------------------------------------------------
#
#   image[0][1] is an x-slice through a volume with colour coding
#
#--------------------------------------------------------------------------

    $plane_object = ILT::PlaneObject->new_canonical( Sagittal_axis, -10 );
    $view = ILT::View->new_canonical( Left_view );
    $volume_object = ILT::VolumeObject->new( "Data/volume1.mnc" );

    $scene_object = 
                  ILT::ColourObject->new_volume_colouring(
                       ILT::IntersectionObject->new( $plane_object,
                                                     $volume_object ),
                       $volume_object, Hot_metal_scale, 50, 150 );

    $image_info = ILT::ImageInfo->new( $scene_object, $view );
    $layout->image_info( $layout->row_col_to_index(0,1), $image_info );

#--------------------------------------------------------------------------
#
#   image[0][2] is three colour-coded slices with a three-d view
#
#--------------------------------------------------------------------------

    $plane_object1 = ILT::PlaneObject->new_canonical( Sagittal_axis, 0 );
    $plane_object2 = ILT::PlaneObject->new_canonical( Coronal_axis, 0 );
    $plane_object3 = ILT::PlaneObject->new_canonical( Transverse_axis, 0 );
    $view = ILT::View->new_arbitrary( -1, -2, -1, 0, 0, 1 );
    $volume_object = ILT::VolumeObject->new( "Data/volume1.mnc" );

    $coloured_slice1 = ILT::ColourObject->new_volume_colouring(
                           ILT::IntersectionObject->new( $plane_object1,
                                                         $volume_object ),
                           $volume_object, Hot_metal_scale, 50, 150 );
    $coloured_slice2 = ILT::ColourObject->new_volume_colouring(
                           ILT::IntersectionObject->new( $plane_object2,
                                                         $volume_object ),
                           $volume_object, Hot_metal_scale, 50, 150 );
    $coloured_slice3 = ILT::ColourObject->new_volume_colouring(
                           ILT::IntersectionObject->new( $plane_object3,
                                                         $volume_object ),
                           $volume_object, Hot_metal_scale, 50, 150 );

    $union = ILT::UnionObject->new( $coloured_slice1,
                               $coloured_slice2,
                               $coloured_slice3 );

    $scene_object = ILT::RenderObject->new( $union );
    $scene_object->lighting_state( True );

    $image_info = ILT::ImageInfo->new( $scene_object, $view );
    $layout->image_info( $layout->row_col_to_index(0,2), $image_info );

#--------------------------------------------------------------------------
#
#   image[0][3] is an x-slice through a PET volume overlaid on average MRI
#
#--------------------------------------------------------------------------

    $plane_object = ILT::PlaneObject->new_canonical( Sagittal_axis, -10 );
    $view = ILT::View->new_canonical( Left_view );
    $mri_volume = ILT::VolumeObject->new( "Data/volume1.mnc" );
    $pet_volume = ILT::VolumeObject->new(
           "/avgbrain/brain/images/mni_demo_fdg_normal_pet_tal.mnc.gz" );
    $slice_object = ILT::IntersectionObject->new( $plane_object,
                                             $mri_volume ),


    $coloured_mri = ILT::ColourObject->new_volume_colouring( $slice_object,
                           $mri_volume, Gray_scale, 50, 150 );

    $scene_object = ILT::ColourObject->new_volume_colouring( $coloured_mri,
                                      $pet_volume, Spectral_scale,
                                      400, 500 );
    $scene_object->under_colour( "transparent" );
    $scene_object->opacity( .5 );

    $image_info = ILT::ImageInfo->new( $scene_object, $view );
    $layout->image_info( $layout->row_col_to_index(0,3), $image_info );

#--------------------------------------------------------------------------
#
#   image[1][0] is a right view of a lit surface
#
#--------------------------------------------------------------------------

    $surface_object = ILT::GeometricObject->new( "Data/surf2.obj" );
    $view = ILT::View->new_canonical( Right_view );

    $scene_object = ILT::RenderObject->new( $surface_object );
    $scene_object->lighting_state( True );

    $image_info = ILT::ImageInfo->new( $scene_object, $view );
    $layout->image_info( $layout->row_col_to_index(1,0), $image_info );

#--------------------------------------------------------------------------
#
#   image[1][1] is a cross section of a surface
#
#--------------------------------------------------------------------------

    $plane_object = ILT::PlaneObject->new_canonical( Sagittal_axis, -40 );
    $surface_object = ILT::GeometricObject->new( "Data/surf2.obj" );
    $view = ILT::View->new_canonical( Right_view );

    $cross = ILT::IntersectionObject->new( $plane_object, $surface_object ),
    $scene_object = $cross;

    $image_info = ILT::ImageInfo->new( $scene_object, $view );
    $layout->image_info( $layout->row_col_to_index(1,1), $image_info );

#--------------------------------------------------------------------------
#
#   image[1][2] is a cross section of a surface superimposed on a colour_coded
#               slice
#
#--------------------------------------------------------------------------

    $plane_object = ILT::PlaneObject->new_canonical( Sagittal_axis, -40 );
    $surface_object = ILT::GeometricObject->new( "Data/surf2.obj" );
    $volume_object = ILT::VolumeObject->new( "Data/volume1.mnc" );
    $view = ILT::View->new_canonical( Right_view );

    $cross = ILT::IntersectionObject->new( $plane_object, $surface_object );

    $coloured_slice = ILT::ColourObject->new_volume_colouring(
                           ILT::IntersectionObject->new( $plane_object,
                                                    $volume_object ),
                           $volume_object, Gray_scale, 50, 150 );

    $scene_object = ILT::UnionObject->new( $cross, $coloured_slice );

    $image_info = ILT::ImageInfo->new( $scene_object, $view );
    $layout->image_info( $layout->row_col_to_index(1,2), $image_info );

#--------------------------------------------------------------------------
#
#   image[1][3] is a surface colour coded with a volume
#
#--------------------------------------------------------------------------

    $surface_object = ILT::GeometricObject->new( "Data/surf2.obj" );
    $volume_object = ILT::VolumeObject->new(
           "/avgbrain/brain/images/mni_demo_fdg_normal_pet_tal.mnc.gz" );
    $view = ILT::View->new_canonical( Left_view );

    $coloured_surface = ILT::ColourObject->new_volume_colouring(
                             $surface_object,
                             $volume_object, Spectral_scale, 300, 350 );
    $coloured_surface->under_colour( "white" );

    $scene_object = ILT::RenderObject->new( $coloured_surface );
    $scene_object->lighting_state( True );

    $image_info = ILT::ImageInfo->new( $scene_object, $view );
    $layout->image_info( $layout->row_col_to_index(1,3), $image_info );

#--------------------------------------------------------------------------
#
#   image[2][0] is a set of cross sections of a surface
#
#--------------------------------------------------------------------------

    $plane_object1 = ILT::PlaneObject->new_canonical( Sagittal_axis, -50 );
    $plane_object2 = ILT::PlaneObject->new_canonical( Sagittal_axis, -25 );
    $plane_object3 = ILT::PlaneObject->new_canonical( Sagittal_axis, 0 );
    $plane_object4 = ILT::PlaneObject->new_canonical( Sagittal_axis, 25 );
    $plane_object5 = ILT::PlaneObject->new_canonical( Sagittal_axis, 50 );
    $surface_object = ILT::GeometricObject->new( "Data/surf2.obj" );
    $view = ILT::View->new_arbitrary( 1, .5, 0, 0, 0, 1 );

    $cross1 = ILT::IntersectionObject->new( $plane_object1, $surface_object ),
    $cross2 = ILT::IntersectionObject->new( $plane_object2, $surface_object ),
    $cross3 = ILT::IntersectionObject->new( $plane_object3, $surface_object ),
    $cross4 = ILT::IntersectionObject->new( $plane_object4, $surface_object ),
    $cross5 = ILT::IntersectionObject->new( $plane_object5, $surface_object ),

    $union = ILT::UnionObject->new( $cross1, $cross2, $cross3, $cross4,
                                    $cross5 );
    $render_object = ILT::RenderObject->new( $union );
    $render_object->lighting_state( True );
    $render_object->line_width( 2 );

    $image_info = ILT::ImageInfo->new( $render_object, $view );
    $layout->image_info( $layout->row_col_to_index(2,0), $image_info );

#--------------------------------------------------------------------------
#
#   now generate the images
#
#--------------------------------------------------------------------------

    $layout->generate_image( "smorgasbord.rgb", 900, 600 );
