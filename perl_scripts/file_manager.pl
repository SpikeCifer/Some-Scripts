#!/usr/bin/perl -w
use v5.30;

use strict;
use warnings;

my $OUTPUT_FILE = "catalogue.md";
my $DEFAULT_DIR = "default";

my $IGNORE_FILES = qr/(\A\.\.?\Z)|\.(git)|(pl)|(md)\Z/; # Ignore .git, .md, and . files
my $MAX_DEPTH = 6; # There are no headers lower than 6, at which point you should reconsider your structure

my %functions_hash = (
    'build' => \&build,
    'help' => \&help,
    'reflect' => \&reflect,
);

my %function_descriptions = (
    'build' => "Reads the catalogue file and creates the described stucture",
    'help' => "Presents description of subroutines",
    'reflect' => "Read the current structure and creates a new catalogue file",
);

sub help {
    foreach my $key (sort keys %functions_hash) {
        print "$key => $function_descriptions{$key}\n"
    }
}

sub format_dir_name {
    my $current_dir = $_[0];
    my $depth = $current_dir =~ tr/\///; # Count number of / to deduce subfolder level
    my $dir_title = "";

    $dir_title = "\n" if $depth > 0;
    $dir_title .= "#" x ($depth + 1) . " ";
    $current_dir eq "." ? $dir_title .= "current directory" : $dir_title .= substr($current_dir, rindex($current_dir,"/") + 1);
    $dir_title . "\n";
}

sub reflect {
    unless (open FILE, ">".$OUTPUT_FILE) {
        die "Unable to create $OUTPUT_FILE";
    }

    my @dirs_queue = (".");
    my %traversed;

    while (my $current_dir = shift @dirs_queue) {
        opendir(DIR, "$current_dir") or die "Cannot open $current_dir\n";
        my @files = readdir(DIR);
        closedir(DIR);

        print FILE format_dir_name($current_dir);
        foreach my $file (@files) {
            next if $file =~ $IGNORE_FILES;
            
            my $path = "$current_dir/$file";
            
            if (-d $path) {
                next if $traversed{$path};
                $traversed{$path} = 1;
                push @dirs_queue, $path;
                next;
            }

            print FILE "- $file\n";
        } 
    }
    print "Finished writing down files!\n";
}

sub main {
    unless (exists $functions_hash{$ARGV[0]}) { 
        print "Subroutine \"$ARGV[0]\" not found, input \"help\" for a list of available subroutines\n";
        return $_;
    } 

    $functions_hash{$ARGV[0]}(); 
}

main();
