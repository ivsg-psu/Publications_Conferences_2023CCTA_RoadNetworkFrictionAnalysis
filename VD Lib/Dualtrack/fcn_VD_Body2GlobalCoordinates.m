function dydt = fcn_VD_Body2GlobalCoordinates(~, y, U, V, r)
%% fcn_VD_Body2GlobalCoordinates
%   This function calculates velocites in global coordinates.
%
% FORMAT:
%
%   dydt = fcn_VD_Body2GlobalCoordinates(~, y, U, V, r)
%   dydt ~ [Xdot; Ydot; Phidot]
%
% INPUTS:
%
%   y: A 3x1 vector of global pose [X; Y; Phi] OR [East; North; Phi]
%   U: Longitudinal velocity [m/s]
%   V: Lateral velocity [m/s]
%   r: Yaw rate [rad/s]
%
% OUTPUTS:
%
%   dydt: A 3x1 vector of velocities in global coordinates
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
    if 5 ~= nargin
        error('Incorrect number of input arguments.')
    end
    
    % Check the inputs
    fcn_VD_checkInputsToFunctions(y,'vector3');
    fcn_VD_checkInputsToFunctions(U,'non negative');
    fcn_VD_checkInputsToFunctions(V,'number');
    fcn_VD_checkInputsToFunctions(r,'number');
end

%% Calculate velocities in Global coordinates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _       
%  |  \/  |     (_)      
%  | \  / | __ _ _ _ __  
%  | |\/| |/ _` | | '_ \ 
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
psi = y(3);

dXdt   = U*cos(psi)-V*sin(psi);
dYdt   = U*sin(psi)+V*cos(psi);
dPhidt = r;
dydt   = [dXdt; dYdt; dPhidt];

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