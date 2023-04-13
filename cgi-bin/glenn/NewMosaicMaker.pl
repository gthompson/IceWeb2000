#!/usr/bin/perl -w
# This script takes output from 'Make Mosaic' form
# and creates spectrogram mosaic for selected volcano
# between times given

# Setup stuff
# Setup paths & modules
use lib  "/usr/local/apache/cgi-bin/glenn";
use lib "$ENV{ANTELOPE}/data/perl";
use Datascope;
use mosaic_maker qw(make_spectrogram_mosaic read_spectrogram_names plots_per_day);
use local_time qw(get_local_time);

# Get the data submitted from ssamarchive.html
#$form = <STDIN>;
$form="Volcano=Shishaldin&StartHours=2&EndHours=0";

# Strip individual variables from input stream
$form=~ s/=/&/g;
$form=~ s/\+/ /g;
@mix = split(/&/,$form);
shift @mix;
$volcano=shift @mix;
shift @mix;
$shours=shift @mix;
shift @mix;
$ehours=shift @mix;
print "$volcano $shours $ehours\n";

# check for silliness
if ($shours<=$ehours) {
	print "<p>\nFirst number must be bigger than second number\n";
} else {
	$call_type="request";
	make_spectrogram_mosaic($volcano,$shours,$ehours,$call_type);
};
