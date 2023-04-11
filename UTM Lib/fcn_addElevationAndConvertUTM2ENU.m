function [east, north, up] = fcn_addElevationAndConvertUTM2ENU(path,X,Y,elevation_map,lat0,lon0,h0,wgs84,varargin)
%%%%%%%%%%%%%% Function fcn_addElevationAndConvertUTM2ENU_VT %%%%%%%%%%%%%%
% Purpose:
%   fcn_addElevationAndConvertUTM2ENU_VT uses UTM coordinates and the
%   output of fcn... to calculate elevation (altitude) for the raw vehicle
%   trajectory. Then the calculated altitude, LLA reference points,
%   and latitude and longitude values from raw_trajectory are used to
%   convert LLA to ENU.
%
% Format:
%   [cg_east_VT, cg_north_VT, cg_up_VT] =
%   fcn_addElevationAndConvertUTM2ENU_VT...
%       (raw_trajectory,X,Y,elevation_map,lat0,lon0,h0,wgs84)
%
% INPUTS:
%   raw trajectory: specifically, position_front_x (UTM x),
%   position_front_y (UTM y), latitude_front, longitude_front
%   lat0: latitude reference point to convert lla to enu
%   lon0: longitude reference point to convert lla to enu
%   h0: altitude reference point to convert lla to enu
%   wgs84: a referenceEllipsoid object for the World Geodetic System of 1984
%
% OUTPUTS:
%   cg_east_VT: east coordinate of the vehicle trajectory
%   cg_north_VT: east coordinate of the vehicle trajectory
%   cg_up_VT: east coordinate of the vehicle trajectory

% DEPENDENCIES:
%   fcn_addElevationToPath
%
% Author:  Juliette Mitrovich
% Created: 2023-01-17
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
flag_do_plots = 0; % % Flag to plot the final results

%% Check for variable argument inputs (varargin)

% Does user want to show the plots?
if 9 == nargin
    temp = varargin{end};
    if ~isempty(temp) % Did the user NOT give an empty figure number?
        fig_num = temp;
        figure(fig_num);
        flag_do_plots = 1;
    end
else
    flag_do_plots = 0;
end
%% Add elevation to the State College road-network
X_path = path(:,1);
Y_path = path(:,2);

% 1. convert utm to ll
[lat, lon] = utm2ll(X_path,Y_path,18);

% add elevation to to the path
% 2. find the min and max of X and Y for the RCL of SCE
X_path_min = min(X_path);
X_path_max = max(X_path);
Y_path_min = min(Y_path);
Y_path_max = max(Y_path);

% 3. limit X and Y to region you're looking at
Xnew = X(X>=X_path_min & X<=X_path_max & ...
    Y>=Y_path_min & Y<=Y_path_max);
Ynew = Y(X>=X_path_min & X<=X_path_max & ...
    Y>=Y_path_min & Y<=Y_path_max);

% 4. add elevation
alt = fcn_addElevationToPath([X_path Y_path],Xnew,Ynew,elevation_map);

% if alt is NOT empty, calculate ENU
if isempty(alt) == 0
    [east, north, up] = geodetic2enu(lat, lon,...
        alt, lat0, lon0, h0, wgs84);
else % if it is empty, set ENU to empty variables
    east = [];
    north = [];
    up = [];    
end
%% Plot the data?
if flag_do_plots
    % plot the final XY result
    figure(fig_num);
    hold on;
    
    % Plot the reference trajectory first
    plot(east,north,'b.');
    hold on
    plot(east,north,'k-');
    title('Road Centerline of the SCE Network in ENU Coordinates', 'Interpreter', 'latex', 'Fontsize', 13);
    xlabel('East [m]', 'Interpreter', 'latex', 'Fontsize', 13);
    ylabel('North [m]', 'Interpreter', 'latex', 'Fontsize', 13); 
    axis equal
    grid on
end
end