function wheel_torque = fcn_VD_velocityController(longitudinal_velocity,...
                        target_longitudinal_velocity,controller)
%% fcn_VD_velocityController
%   This function computes wheel torque depending on the current 
%   longitudinal velocity and desired longitudinal velocity of the vehicle.
%
% FORMAT:
%
%   wheel_torque = fcn_VD_velocityController(longitudinal_velocity,...
%                   target_longitudinal_velocity,controller)
%
% INPUTS:
%
%   longitudinal_velocity: Longitudinal velocity of the vehicle [m/s].
%   target_longitudinal_velocity: Desired longitudinal velocity of the vehicle [m/s].
%   controller: MATLAB structure containing controller parameters.
%
% OUTPUTS:
%
%   wheel_torque: A 4x1 vector of wheel torque [Nm]
%   [Front Left; Front Right; Rear Left; Rear Right]
%
% This function was written on 2021/08/12 by Satya Prasad
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
    if 3~=nargin
        error('Incorrect number of input arguments.')
    end
    
    % Check the inputs
    fcn_VD_checkInputsToFunctions(longitudinal_velocity,'non negative');
    fcn_VD_checkInputsToFunctions(target_longitudinal_velocity,'non negative');
end

%% Calculate Wheel Torque
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _       
%  |  \/  |     (_)      
%  | \  / | __ _ _ _ __  
%  | |\/| |/ _` | | '_ \ 
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Kp = controller.velocity_Pgain; % proportional gain

if target_longitudinal_velocity >= longitudinal_velocity
    wheel_torque = Kp*(target_longitudinal_velocity-longitudinal_velocity)*[0; 0; 1; 1];
else
    % This should really be distributed according to the load transfer (or
    % static weight distribution at minimum)
    wheel_torque = Kp*(target_longitudinal_velocity-longitudinal_velocity)*[.6; .6; .4; .4];
end

% Saturation (Maximum acceleration torque is 200Nm and brake torque is 400Nm)
wheel_torque(200<wheel_torque)  = 200;
wheel_torque(-400>wheel_torque) = -400;

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