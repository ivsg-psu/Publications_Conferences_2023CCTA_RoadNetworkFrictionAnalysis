function fcn_VD_plotTrajectory(trajectory, varargin)
%% fcn_VD_plotTrajectory
% Purpose:
%   To plot the trajectory
%
% Inputs:
%   time: A Nx2 vector of trajectory
%
% Returned Results:
%   A plot
%
% Author: Satya Prasad
% Created: 2021_07_03
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
if 1>nargin || 3<nargin
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
set(h_fig, 'Name', 'fcn_VD_plotTrajectory');
width = 600; height = 400; right = 100; bottom = 400;
set(gcf, 'position', [right, bottom, width, height])
clf

plot(trajectory(:,1), trajectory(:,2), 'b.', 'Linewidth', 1)
grid on
hold on
xlabel('East $[m]$', 'Interpreter', 'latex', 'Fontsize', 13)
ylabel('North $[m]$', 'Interpreter', 'latex', 'Fontsize', 13)
axis equal
% Get handle to current axes.
ax = gca;
% Set x and y font sizes.
ax.XAxis.FontSize = 13;
ax.YAxis.FontSize = 13;

% title('Trajectory', 'Interpreter', 'latex', 'Fontsize', 13)
end