%% Purpose:
%   The purpose of the script is to plot friction demand data to its
%   geolocation in the State College Road network
% 
% Author:  Juliette Mitrovich, adapted from Satya Prasad 
% Created: 2022/04/09
% Updated: 2023/04/10

%% Prepare the workspace
clear all %#ok<CLALL>
close all
clc

%% Add path to dependencies
addpath('./Data');

%% Flag trigger
% Decide if you want to plot the min, max, or mean
flag.plotMin = false;
flag.plotMax = true;
flag.plotMean = false;

% Decide which tire data you want to plot
flag.plotFL = true; % flag to plot the front left tire friction
flag.plotFR = false; % flag to plot the front right tire friction
flag.plotRL = false; % flag to plot the real left tire friction
flag.plotRR = false; % flag to plot the rear right tire friction

% State machine that decides the variables to plot
load trajectory_data_3DOF_NoLC.mat
index = 
if flag.plotFL
    if flag.plotMax
        friction_val = 'friction_fl_max';

    elseif flag.plotMin
        friction_val = 'friction_fl_min';
    elseif flag.plotMean
        indices_checkNaN = ~isnan(trajectory_data{:,{'friction_fl_mean'}});
        trajectory_data = trajectory_data(indices_checkNaN,:);
        friction_val = 'friction_fl_mean';
    end
elseif flag.plotFR
    if flag.plotMax
        friction_val = 'friction_fr_max';
    elseif flag.plotMin
        friction_val = 'friction_fr_min';
    elseif flag.plotMean
        indices_checkNaN = ~isnan(trajectory_data{:,{'friction_fr_mean'}});
        trajectory_data = trajectory_data(indices_checkNaN,:);
        friction_val = 'friction_fr_mean';
    end
elseif flag.plotRL
    if flag.plotMax
        friction_val = 'friction_rl_max';
    elseif flag.plotMin
        friction_val = 'friction_rl_min';
    elseif flag.plotMean
        indices_checkNaN = ~isnan(trajectory_data{:,{'friction_rl_mean'}});
        trajectory_data = trajectory_data(indices_checkNaN,:);
        friction_val = 'friction_rl_mean';
    end
elseif flag.plotRR
    if flag.plotMax
        friction_val = 'friction_rr_max';
    elseif flag.plotMin
        friction_val = 'friction_rr_min';
    elseif flag.plotMean
        indices_checkNaN = ~isnan(trajectory_data{:,{'friction_rr_mean'}});
        trajectory_data = trajectory_data(indices_checkNaN,:);
        friction_val = 'friction_rr_mean';
    end
end

%% Convert ENU to LLA
% Set coordinates of local origin for coordinate conversion
lat0 = 40.79365087;
lon0 = -77.86460284;
h0 = 334.719;
wgs84 = wgs84Ellipsoid;

[RCL_latitude,...
     RCL_longitude,...
     RCL_altitude] = enu2geodetic(trajectory_data{:,'RCL_cg_east'},...
    trajectory_data{:,'RCL_cg_north'},trajectory_data{:,'RCL_cg_up'},...
    lat0,lon0,h0,wgs84);

%% Create the color map used to plot the friction
number_of_colormaps = 101;
load color_map.mat

%% Plot the friction demand data
% Find minimum and maximum friction demand
max_friction_demand = max(1.0*trajectory_data{:,{friction_val}});
if 1<max_friction_demand
    max_friction_demand = 1;
end
min_friction_demand = min(1.0*trajectory_data{:,{friction_val}});

% Define colour vector based on friction demand
colormap_indices = round(100*(trajectory_data{:,{friction_val}}-...
                              min_friction_demand)/(max_friction_demand-...
                                                    min_friction_demand))+1;
colormap_indices(colormap_indices>number_of_colormaps) = number_of_colormaps;

% Define axis limits
min_lat = min(RCL_latitude);
max_lat = max(RCL_latitude);
buffer_spacing_lat = 0.05*(max_lat-min_lat);
min_lon = min(RCL_longitude);
max_lon = max(RCL_longitude);
buffer_spacing_lon = 0.05*(max_lon-min_lon);

hFigAnimation = figure(12345); % Opens up the figure with a number
set(hFigAnimation,'Name','Friction Demand','Position',[200, 240, 746, 420]); % Puts a name on the figure and fix its size
figh = geoscatter(RCL_latitude,RCL_longitude,...
           10,FrictionDemandColorMap(colormap_indices,:),'Marker','.','SizeData',100);
geobasemap streets-light; % set the background
geolimits([min_lat-buffer_spacing_lat max_lat+buffer_spacing_lat],...
          [min_lon-buffer_spacing_lon max_lon+buffer_spacing_lon]); % set the lat-lon limits
colormap(FrictionDemandColorMap)
colorbar;
caxis([min_friction_demand, max_friction_demand]);
