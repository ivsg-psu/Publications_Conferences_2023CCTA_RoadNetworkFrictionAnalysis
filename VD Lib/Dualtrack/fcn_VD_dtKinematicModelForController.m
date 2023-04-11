function dydt = fcn_VD_dtKinematicModelForController(t,y,steering_angle,wheel_torque,...
                vehicle,road_properties,type_of_transfer)
%% fcn_VD_dt7dofModelForController
%   This function sets-up a 7-DoF Double-Track vehicle model using Brush
%   tire model.
%
% FORMAT:
%
%   dydt = fcn_VD_dt7dofModelForController(t,y,steering_angle,wheel_torque,...
%   vehicle,road_properties,friction_coefficient,type_of_transfer)
%   dydt ~ [dUdt; dVdt; drdt; domegadt; dXdt; dYdt; dPhidt];
%
% INPUTS:
%
%   t: A number indicating time corresponding to y.
%   y: A 10x1 vector of velocities and pose. [U; V; r; omega; X; Y; Phi]
%   steering_angle: A 4x1 vector of steering angle.
%   wheel_torque: A 4x1 vector of wheel torques.
%   vehicle: MATLAB structure containing vehicle properties.
%   road_properties: MATLAB structure containing road properties.
%   friction_coefficient: A 4x1 vector of friction coefficients.
%   [Front Left; Front Right; Rear Left; Rear Right]
%   type_of_transfer: To decide type of load transfer.
%       'both': both longitudinal and lateral weight transfer
%       'longitudinal': Only longitudinal weight transfer
%       'default': No weight transfer. Any string argument will give this result.
%
% OUTPUTS:
%
%   dydt: A 10x1 vector of accelerations and velocities.
%
% This function was written on 2021/07/07 by Satya Prasad
% Questions or comments? szm888@psu.edu
%

% flag_update: A global variable to decide the value of acceleration at a 
% time-step 't'
% global_acceleration: A global variable that stores accelerations at a
% time-step 't'
global flag_update global_acceleration % change the variable name based on the matlab script
persistent delayed_acceleration % variable to store acceleration in the previous time-step

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
    if 7~=nargin
        error('Incorrect number of input arguments.')
    end
    
    % Check the inputs
    fcn_VD_checkInputsToFunctions(t,'non negative');
    fcn_VD_checkInputsToFunctions(y,'vector4');
    fcn_VD_checkInputsToFunctions(steering_angle,'vector4');
    fcn_VD_checkInputsToFunctions(wheel_torque,'vector4');
    fcn_VD_checkInputsToFunctions(type_of_transfer,'string');
end

%% Implement 7-DoF Vehicle Model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _       
%  |  \/  |     (_)      
%  | \  / | __ _ _ _ __  
%  | |\/| |/ _` | | '_ \ 
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
V = 0; % lateral velocity [m/s]
U = y(1); % longitudinal velocity [m/s]
pose = y(2:4); % position and orientation of the vehicle

%% Normal Forces
if flag_update
    % load transfer is calculated based on the acceleration in the previous
    % time-step 't-deltaT'
    delayed_acceleration = global_acceleration;
end
normal_force = fcn_VD_dtNormalForce(delayed_acceleration(1:2),vehicle,...
                                    road_properties,type_of_transfer);

%% Longitudinal model
dUdt = fcn_VD_longitudinalModel(normal_force,wheel_torque,vehicle,...
                                road_properties);
if flag_update
    % 'global_acceleration' will be updated only in the first call to the
    % function in RK4 method i.e., while computing k1 in 'fcn_VD_RungeKutta'
    global_acceleration = [dUdt; 0; 0; zeros(4,1)];
    flag_update = false;
end

if 0>U
    U = 0;
end
%% Yaw rate
r = fcn_VD_kinematicYawRate(U,steering_angle,vehicle);

%% Body2Global coordinates
DposeDt = fcn_VD_Body2GlobalCoordinates(t,pose,U,V,r);

%% Write to output
dydt = [dUdt; DposeDt];

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