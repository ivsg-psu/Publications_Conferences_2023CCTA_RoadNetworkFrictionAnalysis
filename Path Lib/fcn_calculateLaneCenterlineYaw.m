%%%%%%%%%%%%%% Function fcn_calculateLaneCenterlineYaw %%%%%%%%%%%%%%
% Purpose:
%   fcn_calculateLaneCenterlineYaw calculates the yaw value for a given
%   path. In this case, the path chosen is the LCL, and there can be up to
%   4 lane yaw values that need to be calculated.
% 
% Format:
%   [path1_yaw, path2_yaw, path3_yaw, path4_yaw] = 
%       fcn_calculateLaneCenterlineYaw(path1, path2, path3, path4)
% 
% INPUTS:
%   path1: the first reference path you want to calculate yaw for
%   path2: the second reference path you want to calculate yaw for
%   path3: the third reference path you want to calculate yaw for
%   path4: the fourth reference path you want to calculate yaw for
% 
% OUTPUTS:
%   path1_yaw: Nx1 array
%   path2_yaw: Nx1 array
%   path3_yaw: Nx1 array
%   path4_yaw: Nx1 array
%
% Dependencies
%   fcn_Path_calcYawFromPathSegments


% Author: Juliette Mitrovich
% Created: 2023/01/19
function [path1_yaw, path2_yaw, path3_yaw, path4_yaw] = fcn_calculateLaneCenterlineYaw(path1, path2, path3, path4)
%% Calculate yaw from the LCL path
% Lane 1
if isempty(path1) == 0
    path1_yaw = fcn_Path_calcYawFromPathSegments(path1);
    path1_yaw = path1_yaw(~isnan(path1_yaw(:,1)),:);
    path1_yaw = [path1_yaw; path1_yaw(end)];
else
    path1_yaw = [];
end

% Lane 2
if isempty(path2) == 0
    path2_yaw = fcn_Path_calcYawFromPathSegments(path2);
    path2_yaw = path2_yaw(~isnan(path2_yaw(:,1)),:);
    path2_yaw = [path2_yaw; path2_yaw(end)];
else
    path2_yaw = [];
end

% Lane 3
if isempty(path3) == 0
    path3_yaw = fcn_Path_calcYawFromPathSegments(path3);
    path3_yaw = path3_yaw(~isnan(path3_yaw(:,1)),:);
    path3_yaw = [path3_yaw; path3_yaw(end)];
else
    path3_yaw = [];
end

% Lane 4
if isempty(path4) == 0
    path4_yaw = fcn_Path_calcYawFromPathSegments(path4);
    path4_yaw = path4_yaw(~isnan(path4_yaw(:,1)),:);
    path4_yaw = [path4_yaw; path4_yaw(end)];
else
    path4_yaw = [];
end