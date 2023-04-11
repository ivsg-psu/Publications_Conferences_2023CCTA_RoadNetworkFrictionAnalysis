function [altitude] = fcn_addElevationToPath(path,Xnew,Ynew,alt_ref)
%%%%%%%%%%%%%% Function fcn_addElevationToPath %%%%%%%%%%%%%%
% Purpose:
%   fcn_addElevationToPath uses UTM coordinates of the path input and
%   calculates the elevation of the path
%
% Format:
%   [altitude] = fcn_addElevationToPath(path,Xnew,Ynew,alt_ref)
%
% INPUTS:
%   path: Nx2 array of X and Y coordinates
%   Xnew: Mx1 array
%   Ynew: Mx1 array
%   alt_ref: Px3 array
%
% OUTPUTS:
%   altitude: Nx1 array
% Dependencies
%   none

% Author: Juliette Mitrovich
% Created: 2023/01/19

% parse out the X and Y data from the path input
X = path(:,1);
Y = path(:,2);

Idx = knnsearch([Xnew,Ynew],[X,Y],"K",2);

if length(Idx)>=1 && length(Xnew)>1 && length(Ynew)>1
    % interpolate the altitude (average it)
    path_vector = [Xnew(Idx(:,2))-Xnew(Idx(:,1)),...
        Ynew(Idx(:,2))-Ynew(Idx(:,1))];
    path_segment_length  = sum(path_vector.^2,2).^0.5;
    point_vector = [X-Xnew(Idx(:,1)),...
        Y-Ynew(Idx(:,1))];
    projection_distance  = (path_vector(:,1).*point_vector(:,1)+...
        path_vector(:,2).*point_vector(:,2))...
        ./path_segment_length; % Do dot product
    percent_along_length = projection_distance./path_segment_length;
    altitude = alt_ref(Idx(:,1)) + (alt_ref(Idx(:,2)) - alt_ref(Idx(:,1))).*percent_along_length;
else
    altitude = [];
end

