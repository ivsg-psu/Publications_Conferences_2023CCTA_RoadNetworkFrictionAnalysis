function [target_lookAhead_pose,target_U] = ...
    fcn_VD_snapLookAheadPoseOnToTraversal(pose,reference_traversal,...
    controller)
%% fcn_VD_snapLookAheadPoseOnToTraversal
%   This function finds nearest neighbour on the reference traversal to
%   vehicle pose at a look ahead distance.
%
% FORMAT:
%
%   [target_lookAhead_pose,target_U] = ...
%   fcn_VD_snapLookAheadPoseOnToTraversal(pose,reference_traversal,controller)
%
% INPUTS:
%   pose: A 3x1 vector of current vehicle pose [X; Y; Phi]
%   reference_traversal: MATLAB structure containing X, Y, Yaw, and Station
%   of a reference path.
%   controller: MATLAB structure containing controller parameters.
%
% OUTPUTS:
%   target_lookAhead_pose: A 3x1 vector of target pose at a look ahead
%   distance defined by controller.
%   target_U:
%
% This function was written on 2021/07/12 by Satya Prasad
% Questions or comments? szm888@psu.edu

flag_do_debug = 0; % Flag to plot the results for debugging
flag_check_inputs = 0; % Flag to perform input checking

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(1, 'STARTING function: %s, in file: %s\n', st(1).name, st(1).file);
end

%% Check input arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____                   _       
%  |_   _|                 | |      
%    | |  _ __  _ __  _   _| |_ ___ 
%    | | | '_ \| '_ \| | | | __/ __|
%   _| |_| | | | |_) | |_| | |_\__ \
%  |_____|_| |_| .__/ \__,_|\__|___/
%              | |                  
%              |_| 
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if flag_check_inputs
    % Are there the right number of inputs?
    if 3~=nargin
        error('Incorrect number of input arguments.')
    end
    
    % Check the inputs
    fcn_VD_checkInputsToFunctions(pose,'vector3');
end

%% Find nearest neighbour on the traversal at a look ahead distance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _       
%  |  \/  |     (_)      
%  | \  / | __ _ _ _ __  
%  | |\/| |/ _` | | '_ \ 
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% location of the vehicle if it continues in the same direction
lookAhead_pose = pose+...
    controller.look_ahead_distance*[cos(pose(3)); sin(pose(3)); 0];
% point on the traversal that is nearest to 'lookAhead_pose'
[closest_path_point,~,path_point_yaw,....
    first_path_point_index,...
    second_path_point_index,...
    percent_along_length] = ...
        fcn_Path_snapPointOntoNearestTraversal(lookAhead_pose(1:2)',...
        reference_traversal);
target_lookAhead_pose = [closest_path_point, path_point_yaw]';
% target_U = reference_traversal.Velocity(first_path_point_index);
target_U = reference_traversal.Velocity(first_path_point_index) + ...
    (reference_traversal.Velocity(second_path_point_index) - reference_traversal.Velocity(first_path_point_index)).*percent_along_length;

%% Any debugging?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____       _                 
%  |  __ \     | |                
%  | |  | | ___| |__  _   _  __ _ 
%  | |  | |/ _ \ '_ \| | | |/ _` |
%  | |__| |  __/ |_) | |_| | (_| |
%  |_____/ \___|_.__/ \__,_|\__, |
%                            __/ |
%                           |___/ 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if flag_do_debug
    fprintf(1, 'ENDING function: %s, in file: %s\n\n', st(1).name, st(1).file);
end

end