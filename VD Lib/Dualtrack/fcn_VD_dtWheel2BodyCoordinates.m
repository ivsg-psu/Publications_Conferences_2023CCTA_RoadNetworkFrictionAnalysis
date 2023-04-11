function body_variable = fcn_VD_dtWheel2BodyCoordinates(wheel_variable,...
                         steering_angle)
%% fcn_VD_dtWheel2BodyCoordinates
%   This function transforms variables from wheel to body coordinates
%   It uses double-track vehicle model.
%
% FORMAT:
%
%   body_variable = fcn_VD_dtWheel2BodyCoordinates(wheel_variable,...
%                   steering_angle)
%
% INPUTS:
%
%   wheel_variable: A 4x2 matrix of wheel coordinates.
%   steering_angle: A 4x1 vector of steering angles. [rad]
%
% OUTPUTS:
%
%   body_variable: A 4x2 matrix of body coordinates.
%
% This function was written on 2021/05/21 by Satya Prasad
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
    fcn_VD_checkInputsToFunctions(wheel_variable,'matrix4by2');
    fcn_VD_checkInputsToFunctions(steering_angle,'vector4');
end

%% Convert from Wheel to Body Coordinates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _       
%  |  \/  |     (_)      
%  | \  / | __ _ _ _ __  
%  | |\/| |/ _` | | '_ \ 
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
body_variable = nan(4,2);

body_variable(:,1) = wheel_variable(:,1).*cos(steering_angle)-...
    wheel_variable(:,2).*sin(steering_angle);
body_variable(:,2) = wheel_variable(:,1).*sin(steering_angle)+...
    wheel_variable(:,2).*cos(steering_angle);

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