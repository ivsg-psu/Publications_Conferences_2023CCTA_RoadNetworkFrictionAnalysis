function tire_force = fcn_VD_dtTireForceBrush(slip_angle,wheel_slip,...
                        normal_force,friction_coefficient,vehicle)
%% fcn_VD_dtTireForceBrush
%   This function computes tire forces using Combined-Slip Brush Model.
%   Ref: Tire Modeling and Friction Estimation by Jacob Svendenius
%   It uses double-track vehicle model and brush tire model.
%
% FORMAT: 
%
%   tire_force = fcn_VD_dtTireForceBrush(slip_angle,wheel_slip,...
%                   normal_force,friction_coefficient,vehicle)
%
% INPUTS:
%
%   slip_angle: A 4x1 vector of slip-angles. [rad]
%   [Front Left; Front Right; Rear Left; Rear Right]
%   wheel_slip: A 4x1 vector of wheel slip.
%   [Front Left; Front Right; Rear Left; Rear Right]
%   normal_force: A 4x1 vector of normal forces. [N]
%   [Front Left; Front Right; Rear Left; Rear Right]
%   friction_coefficient: A 4x1 vector of friction coefficients.
%   [Front Left; Front Right; Rear Left; Rear Right]
%   vehicle: MATLAB structure containing vehicle properties
%
% OUTPUTS:
%
%   tire_force: A 4x2 matrix of tire forces. Column-1 is X-direction and
%   Column-2 is Y-direction.
%   [Front Left; Front Right; Rear Left; Rear Right]
%
% This function was written on 2021/05/19 by Satya Prasad
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
    fcn_VD_checkInputsToFunctions(slip_angle,'vector4');
    fcn_VD_checkInputsToFunctions(wheel_slip,'vector4');
    fcn_VD_checkInputsToFunctions(normal_force,'vector4');
    fcn_VD_checkInputsToFunctions(friction_coefficient,'vector4');
end

%% Calculate Tire Forces using Brush Model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _       
%  |  \/  |     (_)      
%  | \  / | __ _ _ _ __  
%  | |\/| |/ _` | | '_ \ 
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
combined_slip = fcn_VD_dtCombinedSlip(slip_angle,wheel_slip); % calculate combined slip

sigma_x = combined_slip(:,1);
sigma_y = combined_slip(:,2);
sigma   = sqrt(sigma_x.^2 + sigma_y.^2);
sigma(0==sigma) = eps; % To avoid division by zero

% eq 4.10, 4.13 on pg 44
Psi = sqrt((vehicle.Cx.*sigma_x).^2 + (vehicle.Ca.*sigma_y).^2)./...
        abs(3*friction_coefficient.*normal_force); % use peak-friction here
Psi(1<=Psi) = 1; % account for pure slip

% Adhesion forces:
% eq 4.14 on pg 44
Fax = vehicle.Cx.*sigma_x.*((1-Psi).^2);
Fay = -vehicle.Ca.*sigma_y.*((1-Psi).^2);

% Slide forces:
% eq 4.17 on pg 46
Fsz = normal_force.*(Psi.^2).*(3-2*Psi);
% eq 4.18 on pg 46
Fsx = (sigma_x./sigma).*friction_coefficient.*Fsz; % use sliding-friction here
Fsy = -(sigma_y./sigma).*friction_coefficient.*Fsz; % use sliding-friction here

tire_force = [Fax+Fsx, Fay+Fsy];

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