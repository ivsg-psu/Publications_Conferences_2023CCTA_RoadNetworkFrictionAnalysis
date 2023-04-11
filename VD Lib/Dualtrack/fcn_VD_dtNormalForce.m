function normal_force = fcn_VD_dtNormalForce(acceleration,vehicle,...
                        road_properties,type_of_transfer)
%% fcn_VD_dtNormalForce
%   This function calculates normal force on all the four wheels.
%   It uses double-track vehicle model.
%
% FORMAT:
%
%   normal_force = fcn_VD_dtNormalForce(acceleration,vehicle,...
%                   road_properties,type_of_transfer)
%
% INPUTS:
%
%   acceleration: A 2x1 vector of accelerations. [m/s^2]
%   [Longitudinal; Lateral]
%   vehicle: MATLAB structure containing vehicle properties.
%   road_properties: MATLAB structure containing road properties.
%   type_of_transfer: To decide type of load transfer.
%       'both': both longitudinal and lateral weight transfer
%       'longitudinal': Only longitudinal weight transfer
%       'default': No weight transfer. Any string argument will give this
%       result.
%
% OUTPUTS:
%
%   normal_force: A 4x1 vector of normal forces.
%   [Front Left; Front Right; Rear Left; Rear Right]
%
% This function was written on 2021/05/20 by Satya Prasad
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
    fcn_VD_checkInputsToFunctions(acceleration,'vector2');
    fcn_VD_checkInputsToFunctions(type_of_transfer,'string');
end

%% Calculate Normal Forces
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
Fz_front = 0.5*vehicle.m*g*cos(road_properties.bank_angle)*cos(road_properties.grade)*...
    (vehicle.b-vehicle.h_cg*tan(road_properties.grade))/vehicle.L;
Fz_rear  = 0.5*vehicle.m*g*cos(road_properties.bank_angle)*cos(road_properties.grade)*...
    (vehicle.a+vehicle.h_cg*tan(road_properties.grade))/vehicle.L;
Fz_lateral_static = vehicle.m*g*sin(road_properties.bank_angle)*(vehicle.h_cg/vehicle.d)*...
    ([vehicle.b; -vehicle.b; vehicle.a; -vehicle.a]/vehicle.L);
normal_force = [Fz_front; Fz_front; Fz_rear; Fz_rear]+Fz_lateral_static; % load transfer due to grade and bank

if strcmpi(type_of_transfer,'both') % Both Longitudinal and Lateral Transfer
    Fz_longitudinal = vehicle.m*acceleration(1)*(vehicle.h_cg/vehicle.L)*[-0.5; -0.5; 0.5; 0.5];
    Fz_lateral      = vehicle.m*acceleration(2)*(vehicle.h_cg/vehicle.d)*([-vehicle.b; vehicle.b; -vehicle.a; vehicle.a]/vehicle.L);
    normal_force    = normal_force + Fz_longitudinal + Fz_lateral;
elseif strcmpi(type_of_transfer,'longitudinal') % Only Longitudinal Transfer
    Fz_longitudinal = vehicle.m*acceleration(1)*(vehicle.h_cg/vehicle.L)*[-0.5; -0.5; 0.5; 0.5];
    normal_force    = normal_force + Fz_longitudinal;
end

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