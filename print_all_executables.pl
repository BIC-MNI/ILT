#!/usr/local/bin/perl5 -w

    use  strict;
    use  ILT::Executables;

    my( @execs, $exec, $actual_path );

    @execs = get_executable_list();

    foreach $exec ( @execs )
    {
        $actual_path = `which $exec`;

        print( "$exec :\n",
               "\n",
               "        $actual_path\n" );
    }
