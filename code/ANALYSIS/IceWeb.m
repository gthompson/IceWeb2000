checkdate.m                                                                                         0100664 0002324 0001604 00000001160 07005405421 0013472 0                                                                                                    ustar 00glenn                           guest                           0000040 0000027                                                                                                                                                                        function [errorflag]=checkdate(day,mon,yr);
errorflag = 0;
switch mon
	case 1, ndays = 31;
	case 2, ndays = 28;
	case 3, ndays = 31;
	case 4, ndays = 30;
	case 5, ndays = 31;
	case 6, ndays = 30;
	case 7, ndays = 31;
	case 8, ndays = 31;
	case 9, ndays = 30;
	case 10, ndays = 31;
	case 11, ndays = 30;
	case 12, ndays = 31;
	otherwise, disp(' '), disp('month is invalid'), errorflag = 1;
end
if (mod(yr,4) == 0) & (yr~=2000) & (mon == 2)
	ndays = 29;
end
if (day<1) | (day>ndays)
	disp(' '), disp('day is invalid');
	errorflag = 1;
end
if (yr<1996) | (yr>year(now))
	disp(' '), disp('year is invalid');
	errorflag = 1;
end
                                                                                                                                                                                                                                                                                                                                                                                                                disp_menu.m                                                                                         0100664 0002324 0001604 00000001235 07016572457 0013565 0                                                                                                    ustar 00glenn                           guest                           0000040 0000027                                                                                                                                                                        function disp_menu(volname,snum,enum)
disp(' ');
disp(' ');
disp(' ');
disp('************************');
disp(' ');
disp(['Volcano    = ',volname]);
disp(['Start date = ',datestr(snum,0)]);
disp(['End date   = ',datestr(enum,0)]);
disp(' ');
disp(['***** MENU *****']);
disp(['(1)  Standard Reduced Displacement Plot']);
disp(['(2)  Spectrograms']);
disp(['(3)  High resolution Dr plot - Not currently available']);
disp(['(4)  Spectral bands plot']);
disp(['(5)  Spectral ratios plot']);
disp(['(6)  Enter new date range']);
disp(['(7)  Enter new volcano']);
disp(['(8)  Close all figure windows']);
disp(['(9)  Save figure to postscript file']);
disp(['(0)  EXIT']);
                                                                                                                                                                                                                                                                                                                                                                   doerte.m                                                                                            0100664 0002324 0001604 00000001256 07005405314 0013050 0                                                                                                    ustar 00glenn                           guest                           0000040 0000027                                                                                                                                                                        function doerte(dr,t,volname,numstations,stations,weatherstation,snum,enum);
days=enum-snum

figure

% HACK - code below assumes there are 5 stations per volcano!
l=length(dr);
if numstations<5
	for c=numstations+1:5
		dr(1:l,c)=ones(1:l,1)*NaN;
		t(1:l,c)=dr(1:l,c);
	end
end


ystr = sprintf('Dr (cm^2)');
plot(t(:,5),dr(:,5),'c+',t(:,4),dr(:,4),'m+',t(:,3),dr(:,3),'g+', ...
t(:,2),dr(:,2),'r+',t(:,1),dr(:,1),'b+');

% Grid it!
grid

datetick('x',15);

creation_time = epoch2dnum(0);

% Add title and axes labels
tstr=sprintf('Last data point is %s UT',datestr(max(max(t)),0));
title(tstr,'Color',[0 0 0],'FontSize',[10], 'FontWeight',['bold']');
xlabel('UT time'); 
ylabel(ystr); 
                                                                                                                                                                                                                                                                                                                                                  dr_plot_request.m                                                                                   0100664 0002324 0001604 00000002400 07017024211 0014765 0                                                                                                    ustar 00glenn                           guest                           0000040 0000027                                                                                                                                                                        function [stations]=dr_plot_request(volcano,snum,enum);

global TRUE FALSE;
days=enum-snum;

% use which stations?
[stations,numstations]=stations_to_use(volcano);

% station corrections?
choice=input('Do you want to apply station corrections (y/n) ? ','s');
if lower(choice(1))=='y'
	SCF=TRUE;
else
	SCF=FALSE;
end

% load drs data (for all plots)
for station_num=1:numstations
	[t,y,DATA_FOUND(station_num)]=...
	load_dr_data(volcano,stations{station_num},snum,enum);
	if SCF==TRUE
		sc(station_num)=input(['Enter station correction for ',stations{station_num}]);
		y=y*sc(station_num);
	else
		sc(station_num)=1;
	end
	drs{station_num}=y;
	dnum{station_num}=t;
end

if sum(DATA_FOUND)>=1
	choice=input(['Do you want (1) linear or (2) log scale  (3) average ? ']);

	switch choice
		case 1, plotlindr(dnum,drs,volcano,stations,snum,enum);
		case 2, plotdr(dnum,drs,volcano,stations,snum,enum);
		case 3, plotdrav(dnum,drs,stations,snum,enum);
	end

	if choice~=3
		lchoice = input('Add legend (y/n) ? ','s');
		if lchoice(1)=='y' | lchoice(1)=='Y'
			for station_num=1:numstations
				labels{station_num}=sprintf('%s %5.2f',stations{station_num},sc(station_num));
			end
			legend(labels,0);
		end
	end
else
	disp('No data was found to match your request');
end
disp(stations);
                                                                                                                                                                                                                                                                drs_20s.m                                                                                           0100664 0002324 0001604 00000007734 07005405157 0013056 0                                                                                                    ustar 00glenn                           guest                           0000040 0000027                                                                                                                                                                        function drs_20s(volcano,snum,enum)
% Glenn Thompson, April 1999
% Usage: create_av20s_plot(volcano,snum,enum)
% 
% Input Arguments: 
% volcano 	- name of volcano
% snum		- start date/time in Matlab datenum format
% enum 		- end   date/time in Matlab datenum format
% 
% Example:
% create_av20s_plot('Shishaldin',datenum(1999,4,18),datenum(1999,4,20))
% this will something resembling a reduced displacement plot for
% Shishaldin between 18 April 1999 and 20 April 1999. 
%
% The data plotted are 20 second aervages of seismic amplitude corrected
% for distance and instrument response. All dates are Universal time.
%
% This function is part of the IceWeb system. 

% no warnings
warning off

close all;

wavelength=1000; %m/s based on 2 Hz peak and 2000 m/s.

% read set of stations for each volcano from controlfile
[numstations,stations,windstation]=read_volcano_record(volcano);

% get distance data
[distances]=get_distance_data(volcano,stations,numstations);

disp(' ');
disp(['Current IceWeb stations for ',volcano,' are:']);
disp(stations);

disp(' ');
choice=input('Do you want to plot all these stations (y/n) ? ','s');
if choice=='n'
	disp(' ');
	numstations=input('Enter number of stations you want to plot  ? ');
	numstations=min(numstations,5);
	disp(' ');
	disp('Enter station-ids for stations you want plotting: ');
	stations={};
	for c=1:numstations
		stations{c}=input(['Enter station id ',num2str(c),' ? '],'s');
	end
	disp(['The following stations will be plotted:']);
	disp(stations);
end


% loop over all stations in controlfile for this volcano
for c=numstations:-1:1
	sta=stations{c};
	l2=0;

	% Load transfer function for this station & distance from volcano summit
	instrument_response_file=[RESPONSE,'/',sta,'.ext'];

	if exist(instrument_response_file,'file')==2
		eval(['load ',instrument_response_file]);
		eval(['instr_resp = ',sta,'* 1000;']);  % counts/m
correction_factor=10000*sqrt(distances(c)).*sqrt(wavelength)/instr_resp(8);


		% loop over all specified days
		for dnum=floor(snum):floor(enum)
			% get day, month & year
			% this is used for filenames
			yr=num2str(year(dnum));
			mnth=num2str(month(dnum));
			if length(mnth) < 2
				mnth=['0',mnth];
			end
			dy=num2str(day(dnum));
			if length(dy) < 2
				dy=['0',dy];
			end
	
			% fetch MeanSquare data for this station & this day
			date_str=[yr,mnth,dy];
			fullpath=[MEAN_SQUARE,'/',date_str,'/',sta,'.ext'];
			file_exists=exist(fullpath,'file');
			if file_exists==2 
				eval(['load ',fullpath]);
				eval(['data = ',sta,';']);
				if size(data)~=[0 0]
					ms=data(:,1);
					timestamp=data(:,2);
				end
				l1=length(ms);
				drs(l2+1:l2+l1,c)=sqrt(ms(1:l1))*correction_factor;
				tstamp(l2+1:l2+l1,c)=timestamp(1:l1);
				l2=l2+l1;
			end
	
		end % loop over days
	else
		disp('no transfer function');
	end	

end % loop over stations

%if numstations < 5
%	for counter=numstations+1:5
%		temp=zeros(size(drs,1),1);
%		drs(:,counter)=temp;
%		tstamp(:,counter)=temp;
%	end
%end
	
%if (now-enum) >2
%	semilogy(tstamp(:,5),drs(:,5),'c.',tstamp(:,4),drs(:,4),'m.',tstamp(:,3),drs(:,3),'g.', ...
%	tstamp(:,2),drs(:,2),'r.',tstamp(:,1),drs(:,1),'b.');
%else
%	semilogy(tstamp(:,5),drs(:,5),'c.',tstamp(:,4),drs(:,4),'m.',tstamp(:,3),drs(:,3),'g.', ...
%	tstamp(:,2),drs(:,2),'r.',tstamp(:,1),drs(:,1),'b.');
%end

		
%a=axis;
%axis([snum enum 1 100]);
%grid;
%if (enum-snum) < 1.8
%	datetick('x',15);
%else
%	datetick('x',7);
%end
%ylabel(['Reduced Displacement (cm^2)']);
%xlabel(['UT date/time']);
%title(['Reduced displacement plot for ',volcano,' starting on ',datestr(snum,1)]);
% Add legend
%legend_str=[stations{numstations},blanks(4-length(stations{1}))];
%for c=1:numstations-1
%	legend_str=[legend_str;stations{numstations-c},blanks(4-length(stations{numstations-c}))];
%end
%legend(legend_str,0);

%figure
l=length(drs);
for c=1:l
	avdrs(c,1)=mean([drs(c,:)]);
	avt(c,1)=mean([tstamp(c,:)]);
end
x=[avt avdrs];
sort(x,1);
plot(x(:,1),x(:,2));
a=axis;
axis([snum enum 0 a(4)]);
grid
datetick('x',15);
xlabel('UT Time');
ylabel('Dr (cm^2)');



rent IceWeb stations for ',volcano,'enterdate.m                                                                                         0100664 0002324 0001604 00000001671 07005405376 0013552 0                                                                                                    ustar 00glenn                           guest                           0000040 0000027                                                                                                                                                                        function [sday,smon,syear,eday,emon,eyear,snum,enum]=enterdate();

flag = 1;
while (flag == 1),
	disp(' ');
        disp('Enter start date');
        sday = input('  day (1-31)  ? ');
        smon = input('  month (1-12)? ');
        syear= input('  year (YYYY) ? ');
        flag = checkdate(sday,smon,syear);
        if (flag == 1)
                disp('Please try again');
        end
end
flag = 1;
while (flag == 1),
	disp(' ');
        disp('Enter end date');
        eday = input('  day (1-31)  ? ');
        emon = input('  month (1-12)? ');
        eyear= input('  year (YYYY) ? ');
        flag = checkdate(eday,emon,eyear);
        if (flag == 1)
                disp('Please try again');
        end
end
snum=datenum(syear,smon,sday);
enum=datenum(eyear,emon,eday);

if snum>enum
	disp(' ');
        disp('Silly! Start date must be BEFORE end date!');
        exit;
end

enum=min(enum,now+9/24);

if enum==floor(enum)
	enum=enum+0.99999;
end
                                                                       entervolcano.m                                                                                      0100664 0002324 0001604 00000000577 07005405354 0014276 0                                                                                                    ustar 00glenn                           guest                           0000040 0000027                                                                                                                                                                        function volname=entervolcano();

% read all controlfile data
volcanoes=read_iceweb_volcanoes;
numvolcanoes=length(volcanoes);

volnumber =0;
while (volnumber<1 | volnumber>numvolcanoes),
	disp(' ');
	disp(['Volcanoes on IceWeb are:']);
	for c=1:numvolcanoes
		disp(['   (',num2str(c),') ',volcanoes{c}]);
	end
	volnumber=input('Which volcano ? ');
end
volname=volcanoes{volnumber};
                                                                                                                                 plotdrav.m                                                                                          0100664 0002324 0001604 00000001202 07016571406 0013420 0                                                                                                    ustar 00glenn                           guest                           0000040 0000027                                                                                                                                                                        function plotdrav(dnum,drs,stations,snum,enum);
numstations=length(stations);
m=0;
for c=1:numstations
	eval(['dr',num2str(c),'=drs{',num2str(c),'};']);
	eval([sprintf('m(c)=length(dr%d);',c)]);
end
m=max(m);
if m~=0
	cmdstr=[];
	t=dnum{1};
	t(m+1)=NaN;
	for c=1:numstations
		eval([sprintf('dr%d(m+1)=NaN;',c)]);
		cmdstr=[cmdstr,' ',sprintf('dr%d;',c)];
	end

	eval(['dr=[',cmdstr,'];']);
	avdr=mean(dr);
	plot(t,avdr);
	xlabel('UT');
	ylabel('Dr (cm^2)');
	%axis([snum enum 0 max(avdr)*1.05]);
	DateTickLabel('x');
	grid;
	%title(sprintf('Average Dr of %s',stations),...
	%'Color',[0 0 0],'FontSize',[16], 'FontWeight',['bold']'); 
end



                                                                                                                                                                                                                                                                                                                                                                                              save_figure.m                                                                                       0100664 0002324 0001604 00000000767 07005405447 0014102 0                                                                                                    ustar 00glenn                           guest                           0000040 0000027                                                                                                                                                                        function save_figure();
disp(' ');
figno=input('Enter number of figure window you want to save      ? ');
if figno>gcf
	disp('figure does not exist');
	return;
end

psfile=input('Enter name of file you wish to save this figure to  ? ','s');
pspath=input('Enter path of directory where you wish to save it   ? ','s');

e=exist(pspath);
switch e
	case 7, disp(['saving to ',pspath,'/',psfile]), eval(['print -dpsc -f',num2str(figno),' ',pspath,'/',psfile]);
	case 0,	disp('directory does not exist');
end
         spectrogram_request.m                                                                               0100664 0002324 0001604 00000004200 07016621543 0015662 0                                                                                                    ustar 00glenn                           guest                           0000040 0000027                                                                                                                                                                        function spectrogram_request(volcano,snum,enum);

% set other important variables
F=0.5:0.1:15.0;  % this is frequency range of archived SSAM data

% use which stations?
[stations,numstations]=stations_to_use(volcano);

% enter time resolution in hours
disp(' ');
disp('Enter time resolution in hours - larger values are quicker to plot');
hours_av=input('Enter time resolution in hours  ? ');

% work out step size
step_size=hours_av*6; % 24 means 4 hours - thats 180 per month

% open a new figure
figure;
	

for frame_num=1:numstations
	% define useful variables
	station_num=numstations+1-frame_num;
	station=stations{station_num};
	for dnum=snum:enum
		[T1,A1]=load_and_av_spec_data(station,dnum,step_size);
		if ~isempty(T1) 
			if exist('T2','var')
				T2=[T2;T1];
				A2=[A2;A1];
			else
				T2=T1; A2=A1;
			end
		end
	end
	if exist('A2','var')
		if ~isempty(A2)
			% calculate position of spectrogram & trace data frames for this station
			[spectrogram_position,trace_position]=...
			calculate_frame_positions(numstations,frame_num,0.9);
			% plot data
			plot_spectrogram(A2',F,T2,station,frame_num,...
			spectrogram_position,[],['']);
		end
	end
	clear A2 T2;
end
tstr=sprintf('%s %s',volcano,datestr(dnum,1));
title(tstr,'Color',[0 0 0],'FontSize',[16], 'FontWeight',['bold']');
add_colorbar;
orient tall;


function [T_av,A_av]=load_and_av_spec_data(station,dnum,step_size);
TRUE=1;

% load spectral data for this day
[yr,mn,dy]=yyyymmdd(dnum);
[data,DATA_FOUND]=load_spec_data(yr,mn,dy,station);

if DATA_FOUND == TRUE & size(data)~=[0 0]
	l=size(data,1);
	T=data(:,1);
	A=data(:,2:147);
			
	if step_size == 1
		T_av=T;
		A_av=A;
	else % average the signal
		i=1;
		first_sample=(i-1)*step_size+1;	
		last_sample=i*step_size;
		while (last_sample <= l),
			T_av(i,1)=nanmean(T(first_sample:last_sample));
			for f_bin=1:146
				A_av(i,f_bin)=nanmean( ...
				A(first_sample:last_sample,f_bin));
			end
			i=i+1;
			first_sample=(i-1)*step_size+1;
			last_sample=i*step_size;
		end
	end
else	
	T_av=[];A_av=[];
end


steps_per_day=144/step_size;	
dT=1/steps_per_day;
if size(T_av,1)<steps_per_day
	A_av(steps_per_day,146)=0;
	T_av=(dnum:dT:dnum+1-dT)';
end

                                                                                                                                                                                                                                                                                                                                                                                                stations_to_use.m                                                                                   0100664 0002324 0001604 00000001301 07015140270 0014775 0                                                                                                    ustar 00glenn                           guest                           0000040 0000027                                                                                                                                                                        function [stations,numstations]=stations_to_use(volcano);

% read stations
[stations,pss,NO_PARAMETER_FILE]=read_iceweb_stations(volcano);
numstations=length(stations);

disp(' ');
disp(['Current IceWeb stations for ',volcano,' are:']);
disp(stations);

disp(' ');
choice=input('Do you want to plot all these stations (y/n) ? ','s');
if lower(choice(1))=='n'
	disp(' ');
	numstations=input('Enter number of stations you want to plot  ? ');
	numstations=min(numstations,5);
	disp(' ');
	disp('Enter stations you want plotting: ');
	stations={};
	for c=1:numstations
		stations{c}=input(['Enter station ',num2str(c),' ? '],'s');
	end
	disp(['The following stations will be plotted:']);
	disp(stations);
end
nt IceWeb stations for ',volcano,' are:']);
disp(stations);

disp(' ');
choice=input('Do you want to plot all these stations (y/n) ? ','s');
if lower(choice(1))=='n'
	disp(' ');
	numstations=input('Enter number of stations you want to plot  ? ');
	numstations=min(numstations,5);
	disp(' ');
	disp('Enter stations you w                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                