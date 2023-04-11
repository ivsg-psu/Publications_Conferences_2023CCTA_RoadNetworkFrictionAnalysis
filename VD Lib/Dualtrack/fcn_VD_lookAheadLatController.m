function steering_angle = fcn_VD_lookAheadLatController(pose,...
                            target_lookAhead_pose,controller)
%% fcn_VD_lookAheadLatController
%   This function computes steering angle depending on the current pose of
%   the vehicle and desired trajectory to be traversed.
%
% FORMAT:
%
%   steering_angle = fcn_VD_lookAheadLatController(pose,...
%                       target_lookAhead_pose,controller)
%
% INPUTS:
%
%   pose: A 3x1 vector of current vehicle pose [X; Y; Phi]
%   target_lookAhead_pose: A 3x1 vector of target pose at a look ahead
%   distance defined by controller.
%   controller: MATLAB structure containing controller parameters.
%
% OUTPUTS:
%
%   steering_angle: A 4x1 vector of steering angles [rad]
%   [Front Left; Front Right; Rear Left; Rear Right]
%
% This function was written on 2021/07/12 by Satya Prasad
% Questions or comments? szm888@psu.edu
%
% Note: Decreasing look_ahead_distance will improve better tracking.

persistent delta_f

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
    fcn_VD_checkInputsToFunctions(target_lookAhead_pose,'vector3');
end

%% Calculate Steering Angle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _       
%  |  \/  |     (_)      
%  | \  / | __ _ _ _ __  
%  | |\/| |/ _` | | '_ \ 
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Kp = controller.steering_Pgain; % proportional gain

% location of the vehicle if it continues in the same direction
lookAhead_pose = pose+...
    controller.look_ahead_distance*[cos(pose(3)); sin(pose(3)); 0];
% expected lateral offset error
lookAhead_lateral_offset = ...
    (target_lookAhead_pose(2)-lookAhead_pose(2))*cos(target_lookAhead_pose(3))-...
    (target_lookAhead_pose(1)-lookAhead_pose(1))*sin(target_lookAhead_pose(3));

% front steering angle: proportional control with lag
if isempty(delta_f)
    delta_f = 0;
else
    delta_f = Kp*lookAhead_lateral_offset;%0.5*(delta_f + Kp*lookAhead_lateral_offset);
end

steering_angle = [delta_f; delta_f; 0; 0];

% Saturation (Maximum steering angle is 30 degrees)
steering_angle(pi/6<steering_angle)  = pi/6;
steering_angle(-pi/6>steering_angle) = -pi/6;

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