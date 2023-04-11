function combined_slip = fcn_VD_dtCombinedSlip(slip_angle,wheel_slip)
%% fcn_VD_dtCombinedSlip
%   This function computes Combined Slip for front left, front right, 
%   rear left and rear right wheels.
%   It uses double-track vehicle model.
%
%   Coordinate System: ISO
%
% FORMAT:
%
%   combined_slip = fcn_VD_dtCombinedSlip(slip_angle,wheel_slip)
%
% INPUTS:
%
%   slip_angle: A 4x1 vector of slip-angles. [rad]
%   [Front Left; Front Right; Rear Left; Rear Right]
%   wheel_slip: A 4x1 vector of wheel slip.
%   [Front Left; Front Right; Rear Left; Rear Right]
%
% OUTPUTS:
%
%   combined_slip: A 4x2 matrix of combined slip. Column-1 is X and
%   Column-2 is Y.
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
    if 2~=nargin
        error('Incorrect number of input arguments.')
    end
    
    % Check the inputs
    fcn_VD_checkInputsToFunctions(slip_angle,'vector4');
    fcn_VD_checkInputsToFunctions(wheel_slip,'vector4');
end

%% Calculate Combined Slip
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _       
%  |  \/  |     (_)      
%  | \  / | __ _ _ _ __  
%  | |\/| |/ _` | | '_ \ 
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
combined_slip = nan(4,2); % Initialize a variable

denominator = wheel_slip+1; % denominator that's used in calculating combined slip
denominator(0==denominator) = eps; % to avoid division by zero

combined_slip(:,1) = wheel_slip./denominator; % sigma-x
combined_slip(:,2) = tan(slip_angle)./denominator; % sigma-y

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