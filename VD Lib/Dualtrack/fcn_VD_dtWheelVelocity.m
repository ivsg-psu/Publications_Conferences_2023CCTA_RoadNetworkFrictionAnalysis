function wheel_velocity = fcn_VD_dtWheelVelocity(U,V,r,vehicle)
%% fcn_VD_dtWheelVelocity
%   This function computes velocities for front left, front right, 
%   rear left and rear right wheels.
%   It uses double-track vehicle model.
%
%   Coordinate System: ISO
%
% FORMAT:
%
%   wheel_velocity = fcn_VD_dtWheelVelocity(U,V,r,vehicle)
%
% INPUTS:
%
%   U: Longitudinal velocity [m/s]
%   V: Lateral velocity [m/s]
%   r: Yaw rate [rad/s]
%   vehicle: MATLAB structure containing vehicle properties
%
% OUTPUTS:
%
%   wheel_velocity: A 4x2 vector of wheel velocities [m/s]
%   First column is along vehicle (X-Direction) and second column is 
%   perpendicular to vehicle (Y-Direction)
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
    if 4~=nargin
        error('Incorrect number of input arguments.')
    end
    
    % Check the inputs
    fcn_VD_checkInputsToFunctions(U,'non negative');
    fcn_VD_checkInputsToFunctions(V,'number');
    fcn_VD_checkInputsToFunctions(r,'number');
end

%% Calculate Wheel Velocities in body coordinates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _       
%  |  \/  |     (_)      
%  | \  / | __ _ _ _ __  
%  | |\/| |/ _` | | '_ \ 
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wheel_velocity = nan(4,2); % Initialize a variable
% Velocity of wheel along vehicle body (X-Direction)
wheel_velocity([1,3],1) = U-0.5*vehicle.d*r; % Left tires
wheel_velocity([2,4],1) = U+0.5*vehicle.d*r; % Right tires
% Velocity of wheel perpendicular to vehicle body (Y-Direction)
wheel_velocity([1,2],2) = V+vehicle.a*r; % Front tires
wheel_velocity([3,4],2) = V-vehicle.b*r; % Rear tires

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