function make_dr_plots(volcano,stations);
% Usage: make_dr_plots(volcano,stations)
% Glenn Thompson, 1999
% If volcano is, or has been, on IceWeb, this function will produce all the requested dr plots
% If no data is found, an error message is generated

days=sort(read_drplots(volcano));

% if no drplots were requested, end function
if ~isempty(days)
	% work out end & begin times in datenum format
	enum=epoch2dnum(0);
	bnum=enum-str2num(days{1});

	% load drs data (for all plots)
	for station_num=1:length(stations)
		[dnum{station_num},drs{station_num},DATA_FOUND(station_num)]=...
		load_dr_data(volcano,stations{station_num},bnum,enum);
	end

	if sum(DATA_FOUND) > 0 % data must have been found for at least 1 station
		% loop for each requested plot (several timescales may have been requeste
		for plot_num=1:length(days)
			% close previous plots
			close all;
			% work out where this data begins
			snum = enum-str2num(days{plot_num});
			% Produce reduced displacement plot
			plotdr(dnum,drs,volcano,stations,snum,enum);
			% save postscript image
			save_postscript_image(volcano,['dr',days{plot_num}]);
		end	
	else
		send_IceWeb_error(['No dr plots produced for ',volcano,' since no dr data found']);
	end
end
