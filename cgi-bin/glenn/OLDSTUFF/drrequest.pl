#!/usr/local/bin/perl
# Glenn Thompson, AVO, 20 May 1998
#
print "Content-type: text/html\n\n";
#
# Set up useful paths
require("/home/glenn/.perl_iceweb_paths");
#
# Get the data submitted from drrequest.html
$form = <STDIN>;
$LEN=length($form);
#$form="Volcano=Iliamna&Days=2&start_day=20061998&end_day=29061998";
#
# Strip individual variables from input stream
$form=~ s/=/&/g;
$form=~ s/\+/ /g;
@mix = split(/&/,$form);
shift @mix;
$volcano=shift @mix;
shift @mix;
if (($LEN>49)&&($LEN<56)) {
	$days=0;
} else {
	$days=shift @mix;
	shift @mix;
} end;
$start_day=shift @mix;
shift @mix;
$end_day=shift @mix;
#print "$volcano $days $start_day $end_day\n";
#exit(0);
#
# Set up array of days per month. Zeroth element is ignored.
@dayspermonth = (0,31,28,31,30,31,30,31,31,30,31,30,31);
#
# Set up error flags - 0 means no error
$cerror=0; $eerror=0; $serror=0;
#############################################################################
# GUTS OF THE ROUTINE
# First part of if statement works out start and end dates for last ($days)
# Second part of if statement strips out start and end dates from
# inputted start and end dates & validates them
#############################################################################
if ($days != 0) {
	($esec,$emin,$ehour,$eday,$emon,$eyear,$weekday,$julianday,$isdst) = gmtime(time);
# month[0] = Jan. Add 1 so month[1]=Jan.	
	$emon=$emon+1;
# 2 digit to 4 digit year conversion - valid until 2090!
	if ($eyear<90) {
		$eyear=$eyear+2000; }
	elsif (($eyear>89)&&($eyear<100)) {
		$eyear=$eyear+1900; }
	end;
# work out start date based on todays date & number of days to plot
	$sday=$eday-$days;
	$smon=$emon;
	$syear=$eyear;
	while ($sday <=0) {
		$smon=$smon-1;
		if ($smon <=0) {
			$smon=12;
			$syear=$syear-1; }
		end;
		$sday=$sday+$dayspermonth[$smon] };
	end; }
else { ############################################# Second part starts here
	$sday=substr($start_day,0,2);
	$smon=substr($start_day,2,2);
	$syear=substr($start_day,4,4);
	$eday=substr($end_day,0,2);
	$emon=substr($end_day,2,2);
	$eyear=substr($end_day,4,4);
	if (($sday<1)||($sday>$dayspermonth[$smon])) {
		$serror=1; } end;
	if (($eday<1)||($eday>$dayspermonth[$emon])) {
		$eerror=1; } end;
	if (($smon<1)||($smon>12)) {
		$serror=1; } end;
	if (($emon<1)||($emon>12)) {
		$eerror=1; } end;
	if (($syear<1996)||($syear>2090)) {
		$serror=1; } end;
	if (($eyear<1996)||($eyear>2090)) {
		$eerror=1; } end;
	$sjuldays=$syear*366+$smon*31+$sday;
	$ejuldays=$eyear*366+$emon*31+$eday;
	if ($ejuldays<=$sjuldays) {
		$cerror=1; } end;
# If some errors were found, indicate them
	print "<html><body><h1>Your request</h1>\n";
	print "Volcano = $volcano<p>\n";
	print "Start date: $sday $smon $syear<br>\nEnd date: $eday $emon $eyear<p>\n";
	if ($serror==1) {
		print "Start date is invalid - must be DDMMYYYY<p>\n"; } end;
	if ($cerror==1) {
		print "End date must be later than start date<p>\n"; } end;
	if ($eerror==1) {
		print "End date is invalid - must be DDMMYYYY<p>\n"; } end;
}
end;
##############################################################################
# Print out the start date and end date to html page
#
#
# If there were no errors, write out data to request file, and run dr plotting
#
if (($serror+$cerror+$eerror)< 1) {
	# Write output to html page
	open(FRED,"> $CGI/drrequest.out") || print "Cant open file\n";
		print(FRED "$volcano\n");
		print(FRED "$sday $smon $syear\n$eday $emon $eyear\n");
	close(FRED);
	chdir("$ICEWEB");
	system("cd $ICEWEB");
	@PATHS=($ICEWEB, $DRHOME, $CGI, $MYWEB, $WIND);
	system("$ICEWEB/drrequest_web @PATHS");
	system("$PPM/ppmtogif $ICEWEB/dr.ppm > $MYWEB/dr.gif");
	print "<center> <img src=\"http://www.avo.alaska.edu/Input/glenn/dr.gif\"></center>\n";
} else {
	print "Please try again<p>\n";
} end;
print "\n</BODY><HTML>";
################# THE END ###########################




