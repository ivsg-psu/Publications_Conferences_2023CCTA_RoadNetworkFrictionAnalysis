function slip_angle = fcn_VD_dtSlipAngle(U,V,r,steering_angle,vehicle)
%% fcn_VD_dtSlipAngle
%   This function computes Slip Angles/Lateral Slip for front left, 
%   front right, rear left and rear right wheels.
%   It uses double-track vehicle model.
%
%   Coordinate System: ISO
%
% FORMAT:
%
%   slip_angle = fcn_VD_dtSlipAngle(U,V,r,steering_angle,vehicle)
%
% INPUTS:
%
%   U: Longitudinal velocity [m/s]
%   V: Lateral velocity [m/s]
%   r: Yaw rate [rad/s]
%   steering_angle: A 4x1 vector of steering angles [rad]
%   [Front Left; Front Right; Rear Left; Rear Right]
%   vehicle: MATLAB structure containing vehicle properties
%
% OUTPUTS:
%
%   slip_angle: A 4x1 vector of slip-angles [rad]
%   [Front Left; Front Right; Rear Left; Rear Right]
%
% This function was written on 2021/05/16 by Satya Prasad
% Questions or comments? szm888@psu.edu
%

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
    if 5~=nargin
        error('Incorrect number of input arguments.')
    end
    
    % Check the inputs
    fcn_VD_checkInputsToFunctions(U,'non negative');
    fcn_VD_checkInputsToFunctions(V,'number');
    fcn_VD_checkInputsToFunctions(r,'number');
    fcn_VD_checkInputsToFunctions(steering_angle,'vector4');
end

%% Calculate Slip-Angles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _       
%  |  \/  |     (_)      
%  | \  / | __ _ _ _ __  
%  | |\/| |/ _` | | '_ \ 
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wheel_velocity = fcn_VD_dtWheelVelocity(U,V,r,vehicle); % calculate wheel velocities
slip_angle = atan(wheel_velocity(:,2)./wheel_velocity(:,1))-steering_angle; % calculate slip angles

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