function fcn_VD_plotStationLongitudinalAcceleration(station, ...
    longitudinal_acceleration, varargin)
%% fcn_VD_plotTimeLongitudinalAcceleration
% Purpose:
%   To plot the longitudinal acceleration against station
%
% Inputs:
%   station: A Nx1 vector of station [m]
%   longitudinal_acceleration: A Nx1 vector of longitudinal acceleration [m/s^2]
%
% Returned Results:
%   A plot
%
% Author: Satya Prasad
% Created: 2022_03_08
% 

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
% Are there the right number of inputs?
if 2>nargin || 3<nargin
    error('Incorrect number of input arguments')
end

%% Plots the inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _       
%  |  \/  |     (_)      
%  | \  / | __ _ _ _ __  
%  | |\/| |/ _` | | '_ \ 
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 3 == nargin
    fig_num = varargin{1};
else
    fig = figure;
    fig_num = fig.Number;
end

h_fig = figure(fig_num);
set(h_fig, 'Name', 'fcn_VD_plotStationLongitudinalAcceleration');
width = 600; height = 400; right = 100; bottom = 400;
set(gcf, 'position', [right, bottom, width, height])

plot(station, longitudinal_acceleration, 'b', 'Linewidth', 1.2)
grid on
ylabel('Longitudinal Acceleration $[m/s^2]$', 'Interpreter', 'latex', 'Fontsize', 13)
xlabel('Station $[m]$', 'Interpreter', 'latex', 'Fontsize', 13)
% Get handle to current axes.
ax = gca;
% Set x and y font sizes.
ax.XAxis.FontSize = 13;
ax.YAxis.FontSize = 13;
ylim([-10 10])

% title('Longitudinal Acceleration', 'Interpreter', 'latex', 'Fontsize', 13)
end