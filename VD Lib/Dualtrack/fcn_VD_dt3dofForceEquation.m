function acceleration = fcn_VD_dt3dofForceEquation(wheel_force,steering_angle,...
                        vehicle,road_properties)
%% fcn_VD_dt3dofForceEquation
%   This function calculates accelerations.
%
% FORMAT:
%
%   acceleration = fcn_VD_dt3dofForceEquation(wheel_force,steering_angle,...
%                   vehicle,road_properties)
%
% INPUTS:
%
%   wheel_force: A 4x2 matrix of tire forces. Column-1 is X-direction and
%   Column-2 is Y-direction.
%   [Front Left; Front Right; Rear Left; Rear Right]
%   steering_angle: A 4x1 vector of steering angles. [rad]
%   [Front Left; Front Right; Rear Left; Rear Right]
%   vehicle: MATLAB structure containing vehicle properties.
%   road_properties: MATLAB structure containing road properties.
%
% OUTPUTS:
%
%   acceleration: A 3x1 vector of accelerations.
%   [longitudinal acceleration; lateral acceleration; yaw acceleration]
%
% This function was written on 2021/05/21 by Satya Prasad and modified by Craig
% Beal on 2023/02/09
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
    if 5~=nargin
        error('Incorrect number of input arguments.')
    end

    % Check the inputs
    fcn_VD_checkInputsToFunctions(wheel_force,'matrix4by2');
    fcn_VD_checkInputsToFunctions(steering_angle,'vector4');
end

%% Calculate accelerations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _       
%  |  \/  |     (_)      
%  | \  / | __ _ _ _ __  
%  | |\/| |/ _` | | '_ \ 
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
g = 9.81; % [m/s^2]
body_force = fcn_VD_dtWheel2BodyCoordinates(wheel_force,steering_angle); % find body forces
% Force and torque balance on the vehicle body
ax = sum(body_force(:,1))/vehicle.m-g*cos(road_properties.bank_angle)*sin(road_properties.grade); % longitudinal acceleration
ay = sum(body_force(:,2))/vehicle.m+g*sin(road_properties.bank_angle); % lateral acceleration
drdt = (((vehicle.d/2)*(-body_force(1,1)+body_force(2,1)-body_force(3,1)+body_force(4,1)))+...
        (vehicle.a*sum(body_force([1,2],2)))-(vehicle.b*sum(body_force([3,4],2))))/vehicle.Izz; % yaw acceleration
acceleration = [ax; ay; drdt];

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
