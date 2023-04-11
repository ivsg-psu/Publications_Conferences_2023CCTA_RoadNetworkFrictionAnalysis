function [path_smooth_LC] = fcn_calculateSmoothLaneChange(a,b,c,d,...
    stations,start_lane,end_lane,path,indices_LC,indices_LC_before,indices_LC_after)
% fcn_calculateSmoothLaneChange
% Takes a path with a lane change discontinuity and smooths it
%
% FORMAT: 
%
%    path_smooth_LC = fcn_calculateSmoothLaneChange(a,b,c,d,...
%    stations,start_lane,end_lane,path,indices_LC,indices_LC_before,indices_LC_after)
%
% INPUTS:
%      a,b,c,d: a scalar value
%      stations: N x 1 vector of station values
%      start_lane: a structure containing the following fields
%                  - X: an N x 1 vector that is a duplicate of the input X
%                  - Y: an N x 1 vector that is a duplicate of the input Y
%                  - Z: an N x 1 vector that is a duplicate of the input Z (if 3D) OR
%                    an N x 1 vector that is a zero array the same length as X
%                    (if 2D)
%                  - Station: the XYZ distance as an N x 1 vector, representing
%                    the distance traveled up to the current point (starting with 0
%                    at the first point)

%      end_lane: a structure containing the following fields
%                  - X: an N x 1 vector that is a duplicate of the input X
%                  - Y: an N x 1 vector that is a duplicate of the input Y
%                  - Z: an N x 1 vector that is a duplicate of the input Z (if 3D) OR
%                    an N x 1 vector that is a zero array the same length as X
%                    (if 2D)
%                  - Station: the XYZ distance as an N x 1 vector, representing
%                    the distance traveled up to the current point (starting with 0
%                    at the first point)
%      indices_LC: N x 1 vector of index values (1 or 0)
%      indices_LC_before: N x 1 vector of index values (1 or 0)
%      indices_LC_after: N x 1 vector of index values (1 or 0)
%      
% OUTPUTS:
%
%      path_smooth_LC: N x 2 vector with [X Y]
%
% DEPENDENCIES:
%
%      None
%
% EXAMPLES:
%      
%       See the script:
%       script_test_fcn_calculateSmoothLaneChange.m for a full test suite. 
%
% This function was written on 2023_02_07 by Juliette Mitrovich
% Questions or comments? jf.mitrovich@gmail.com

%% Store coordinates of the start lane and end lane during the lane change
E_start_lane = start_lane.X(indices_LC);
E_end_lane = end_lane.X(indices_LC);

N_start_lane = start_lane.Y(indices_LC);
N_end_lane = end_lane.Y(indices_LC);

%% Store the coordinates of the path before and after the LC
% E and N coordinates of the path before the lane change
east_before = path(indices_LC_before,1);
north_before = path(indices_LC_before,2);

% E and N coordinates of the path after the lane change
east_after = path(indices_LC_after,1);
north_after = path(indices_LC_after,2);

%% offset the stations so the start of the lane change = 0
stations = stations - stations(1);

%% Recalculate the east and north coordinates during the lane change

% initialize variables
N_lane_change_stations = length(E_start_lane);
north_ref_new = NaN(N_lane_change_stations,1);
east_ref_new = NaN(N_lane_change_stations,1);

for index_LC_calc = 1:N_lane_change_stations
    alpha = d*stations(index_LC_calc)^3 + ...
        c*stations(index_LC_calc)^2 + ...
        b*stations(index_LC_calc) + ...
        a;
    north_ref_new(index_LC_calc) = (1-alpha)*N_start_lane(index_LC_calc) + alpha*N_end_lane(index_LC_calc);
    east_ref_new(index_LC_calc)  = (1-alpha)*E_start_lane(index_LC_calc) + alpha*E_end_lane(index_LC_calc);
end

%% Concatinate the E and N coordinates of the new smooth LC path
east_path  = [east_before; east_ref_new; east_after];
north_path = [north_before;north_ref_new;north_after];

path_smooth_LC = [east_path north_path];


