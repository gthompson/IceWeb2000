# Glenn Thompson, October 1999
# This is a cgi package (set of perl routines) which exports subroutines
# necessary to make spectrogram mosaics
package mosaic_maker_orig;
use lib "/home/iceweb/ICEWEB_UTILITIES";
use iceweb_perl_utilities qw(get_time send_IceWeb_error);
# hard wired path since cgi scripts cannot import environment variables
# enviroment variables not inherited by cgi-scripts,
# so paths must be hard coded (which makes them more
# likely to break!)
use lib "/opt/antelope/4.3u/data/perl";
#use lib "/opt/antelope/4.5/data/perl";
use Datascope;
use FileHandle;
require Exporter;
@ISA=qw(Exporter);
@EXPORT=qw(make_spectrogram_mosaic read_spectrogram_names plots_per_day);
@EXPORT_OK=qw($spectrogram_num @spectrogram $num_spectrograms_per_day $year $mon $mday $hour $min);
$PFS="/home/iceweb/PARAMETER_FILES";

sub make_spectrogram_mosaic {
# Make a spectrogram mosaic beginning $shours ago and ending $ehours ago for $volcano
# This uses the "list_of_recent_spectrogram" for each volcano, since each
# spectrogram gif file name includes a timestamp

	($volcano,$shours,$ehours,$call_type)=@_;

	print "Content-type: text/html\n\n";

	# how long is spectrogram in minutes? Read from parameter file
	$num_mins=pfget("$PFS/parameters.pf","minutes_to_get");

	# work out how many spectrogram plots there are per hour
	$plots_per_hour=60/$num_mins;

	# work out how many plots archived
	$days_in_archive=pfget("$PFS/parameters.pf","days_in_spectrogram_archive");
	$max_hours=$days_in_archive*24;
	if ($shours>$max_hours*$plots_per_hour) {
		report_error("Maximum number of hours is $max_hours");
	}
	else
	{

		# http path to spec directory - read from parameter file
		$SPEC_HTTP=pfget("$PFS/paths.pf","SPEC_HTTP");

		# read in name of recent (e.g. last 3 days) spectrogram gif files for this volcano from "list_of_recent_spectrograms"
		($last_spectrogram_num,@spectrogram)=read_spectrogram_names($volcano);	# error code -1 indicates empty array

		unless ($last_spectrogram_num==-1) {

			if ($call_type eq "auto") {
				$html_file = "$SPEC_GIFS/$volcano/l2h.html";
				$fh=new FileHandle ">$html_file";
			}
			else
			{
				$fh=STDOUT;
			};

			if (defined($fh)) { # output file exists

				# Print first part of html page	
				print $fh "<html><head><title>$shours to $ehours hours ago $num_mins minute spectrograms for $volcano</title>\n";
				print $fh "<META HTTP-EQUIV=\"Refresh\" CONTENT=600; URL=\"$html_file\">\n";
				print $fh "</head>\n";
				print $fh "<body bgcolor=\"#FFFFFF\">\n";
				print $fh "<p align=\"center\"><font size=\"4\"><strong>$volcano Volcano IceWeb Spectrograms<br></strong></font>\n";
				($year,$mon,$mday,$hour,$min)=get_time("local",0);
				print $fh sprintf("<h2><center>Last updated %s:%s (Alaskan time) on %s/%s/%s</center></h2>",$hour,$min,$mday,$mon,$year);
				print $fh "<p align=\"center\"><font size=\"2\">$shours to $ehours hours ago $num_mins minute spectrograms for $volcano;
				details are available by clicking each frame.  Oldest panel is upper left, youngest is lower right.</font><p>\n";
				
				# Middle part of html page 
				for ($h=$shours;$h>$ehours;$h--) {
					print $fh "<!-- $h hours behind--><p align=\"center\"><img src=\"$SPEC_HTTP/$h" . "ha.jpg\">\n";
					for ($panel_num=($h*$plots_per_hour-1);$panel_num>=(($h-1)*$plots_per_hour);$panel_num--) {
						$spectrogram_num=$last_spectrogram_num+$panel_num+1;
						$specpath="$SPEC_HTTP/$volcano/$spectrogram[$spectrogram_num]";
						print $fh "<a href=\"$specpath.gif\"><img src=\"$specpath.2.gif\" width=\"96\" height=\"150\"></a>\n";
					};
					print $fh "</p>\n";
				};
				
				# Print out end part of html page
				$maps="/internal/volcanomaps/$volcano" . "_frame.html";
				if (-e $maps) {
					print $fh "<center><Table border=2 cellpadding=2><TR>\n";
					print $fh "<TD align=middle><A HREF=\"$maps\" > network map </A></TD>\n";
					print $fh "</TR></TABLE>\n";
				};

# fluff to add to spectrograms
$fluff = "<p align=\"center\">These spectrograms are computed by the<A HREF=\"http://giseis.alaska.edu/Input/glenn/IceWeb.html\"> IceWeb system </A>using near-real-time data from the<A HREF=\"http://giseis.alaska.edu/Input/kent/Iceworm.html\"> Iceworm sys

tem </A>at the University of Alaska<A HREF=http://www.gi.alaska.edu/> Geophysical Institute </A>.\n";

				print $fh "$fluff";
				print $fh "<p></body></html>\n";

				# close output file
				$fh->close;
			}
			else
			{
				send_IceWeb_error("Could not open $html_file <p>");
			}
		};
	};	
	return 1;
};
	
sub read_spectrogram_names {	
	# This routine looks up a file which lists filenames of last ($num_spectrogram_plots_per_day * $numdays) spectrograms
	# for a particular volcano. Each spectrogram file is timestamped.

	$volcano=$_[0];
	
	# open file which has list of last num_days of spectrogram names for this volcano
	$SPEC_GIFS=pfget("$PFS/paths.pf","SPEC_GIFS");
	$infile = "$SPEC_GIFS/$volcano/list_of_recent_spectrograms.ext";
	open(IN,$infile);
	if (defined(IN)) {
		$num_spectrograms_per_day=plots_per_day();
		$spectrogram_num=$num_spectrograms_per_day*$num_days;
		while (read(IN, $spectrogram[$spectrogram_num],13)) {
			$spectrogram_num = $spectrogram_num - 1;
			read(IN, $filler,1);
		};
		close(IN);
		print " $spectrogram[$spectrogram_num]\n";
		return ($spectrogram_num,@spectrogram); # in perl, scalars must be returned before arrays
	}
	else
	{
		# for some reason input file cannot be opened - send error message
		send_IceWeb_error("Could not open $infile for input");
		return -1;
	}
};

sub plots_per_day {
# This program works out how many spectrogram plots there should be per day, based on
# parameter "minutes_to_get" in IceWeb parameter file - this is length of spectrogram plots

	$mins_per_day=24*60;
	$num_days=pfget("$PFS/parameters.pf","days_in_spectrogram_archive"); # =7, put in parameter file
	$minutes_per_spectrogram=pfget("$PFS/parameters.pf","minutes_to_get");
	$num_spectrograms_per_day=$mins_per_day/$minutes_per_spectrogram;
	return $num_spectrograms_per_day;
};
