#!/usr/local/bin/perl5 -w

#----------------------------- MNI Header -----------------------------------
#@NAME       : print_all_executables.pl
#@INPUT      : 
#@OUTPUT     : 
#@RETURNS    : 
#@DESCRIPTION: Lists all the executables of ILT, both as they are invoked,
#              and as full path that the shell finds, by using 'which'.
#@METHOD     : 
#@GLOBALS    : 
#@CALLS      :  
#@CREATED    : May. 22, 1998    David MacDonald
#@MODIFIED   : 
#----------------------------------------------------------------------------

    use  strict;
    use  ILT::Executables;

    my( $rcsid ) = "$Header: /private-cvsroot/libraries/ILT/print_all_executables.pl,v 1.2 1998-05-22 14:38:05 david Exp $";

    my( @execs, $exec, $actual_path );

    @execs = get_executable_list();

    foreach $exec ( @execs )
    {
        $actual_path = `which $exec`;

        print( "$exec :\n",
               "\n",
               "        $actual_path\n" );
    }
