function [traversal] = fcn_calculateNewStationsAndCutoffData(reference_traversal,station_interval,cut_off_length)
if isempty(reference_traversal) == 0
%     station_interval       = 1;
    station_interval_start = 0;
    station_interval_end   = reference_traversal.Station(end);
    new_stations           = (station_interval_start:...
        station_interval:station_interval_end)';
    traversal    = fcn_Path_newTraversalByStationResampling...
        (reference_traversal, new_stations);

    traversal = fcn_cutOffTraversalDatapoints(traversal,cut_off_length);
else
    traversal = [];
end