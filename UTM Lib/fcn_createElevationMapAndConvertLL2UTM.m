function [X,Y,elevation_map] = fcn_createElevationMapAndConvertLL2UTM(A)
%%%%%%%%%%%%%% Function fcn_createElevationMapAndConvertLL2UTM %%%%%%%%%%%%%%
% Purpose:
%   fcn_createElevationMapAndConvertLL2UTM creates an elevation map in LLA 
%   from a geotiff file of State College. The elevation map is then 
%   converted from LLA to UTM. The outputs X and Y can be used by functions
%   to add elevation to UTM X and Y coordinates.
% 
% Format:
%   [X,Y,elevation_map] = fcn_createElevationMapAndConvertLL2UTM(A)
% 
% INPUTS:
%   A: an output of the matlab funciton 'readgeoraster'
% 
% OUTPUTS:
%   X: UTM x coordinate of the State College geotiff file
%   Y: UTM y coordinate of the State College geotiff file
%   elevation_map: elevation map of State College
% 
% Author:  Juliette Mitrovich
% Created: 2023-01-17
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Convert lat and lon coordinates to UTM
% interpolate lat and lon limits
LatLim = (39.9994:(1/(3*3600)):41.0006-(1/(3*3600)));
LonLim = (-78.0006+(1/(3*3600)):(1/(3*3600)):-76.9994);

% convert vectors to a grid
[lat_grid,long_grid] = meshgrid(flip(LatLim),LonLim);

% create the elevation map
elevation_map = [lat_grid(:) long_grid(:) A(:)];

% convert lat and lon to UTM
[X,Y] = ll2utm(elevation_map(:,1),elevation_map(:,2),18);
end