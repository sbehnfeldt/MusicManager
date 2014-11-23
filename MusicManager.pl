#!/usr/bin/perl -w
use strict;
use warnings;

use Getopt::Long;
use IO::File;
use File::Copy;





################################################################################
# Global variables
################################################################################
my %version = (
	'major' => 0,
	'minor' => 1,
	'patch' => 0
);

my $minor =
my %opts = (
	'source' => './',
	'print-only' => 1,
	'verbose' => 1,
);


sub usage {
	print "Usage: MusicManager [options] <SRC>\n";
	print "Options:\n";
	print "-p | --print: Print only.  Show the operations that would be executed, but do not actually execute them.\n";
	print "-V | --verbose\n";
	print "-v | --version\n";
}


# Inspect the current directory structure, but don't change anything
sub inspect {
	my $src = shift;   # Where we begin; folder containing all artist folders
	my %dirTree = ();  # Representation of the directory tree structure
	#my %library = ();  # Music library

	opendir( my $fh, $src ) or die $!;
	while ( readdir( $fh )) {
		next if $_ =~ m/^\.{1,2}$/;   # Skip directories '.' and '..'

		if ( -f "$src/$_" ) {
			$dirTree{ $_ } = undef;
			next;
		}

		# A folder under the main folder is an artist folder
		my $artistFolder = $_;
		$dirTree{ $artistFolder } = ();
		opendir( my $artistFh, "$src/$artistFolder" ) or die $!;
		while ( readdir( $artistFh )) {
			next if $_ =~ m/^\.{1,2}$/;   # Skip directories '.' and '..'
			if ( -f "$src/$artistFolder/$_" ) {
				$dirTree{ $artistFolder }{ $_ } = undef;   # Add file to directory tree, but there's nothing underneath it
				next;
			}
			if ( -d "$src/$artistFolder/$_" ) {
				# A folder under an artist folder is an album folder
				my $albumFolder = $_;
				$dirTree{ $artistFolder }{ $albumFolder }= [];
				opendir( my $albumFh, "$src/$artistFolder/$albumFolder" ) or die $!;
				while ( readdir( $albumFh )) {
					next if $_ =~ m/^\.{1,2}$/;   # Skip directories '.' and '..'

					if ( -f "$src/$artistFolder/$albumFolder/$_" ) {
						my $song = $_;
						push( $dirTree{ $artistFolder }{ $albumFolder }, $song );
					}
				}
				next;
			}

			warn "Unknown file $src/$artistFolder/$_\n";
		}
	}

	return \%dirTree;
}





# Print out the directory tree
sub display {
	my $dirTree = shift;
	foreach my $artistFolder (sort keys %$dirTree) {

		print "$artistFolder\n";
		next if ( ! $$dirTree{ $artistFolder });

		foreach my $albumFolder (sort keys $$dirTree{ $artistFolder}) {
			print "\t$albumFolder\n";
			next if ( ! $$dirTree{ $artistFolder }{ $albumFolder });
			if ( defined( $$dirTree{ $artistFolder }{ $albumFolder })) {
				for ( my $i = 0; $i < @{ $$dirTree{ $artistFolder }{ $albumFolder }}; $i++ ) {
					my $song = $$dirTree{ $artistFolder }{ $albumFolder }[ $i ];
					print "\t\t$song\n";
				}
			}
		}
	}
}




################################################################################
# Main Routine
################################################################################



#inspect( "/cygdrive/e/Media/Audio/Music" );
$opts{ 'source' } = 'E:/Media/Audio/Music';
my $t = inspect( $opts{ 'source' });
display( $t );
print "Done.\n";
1;
