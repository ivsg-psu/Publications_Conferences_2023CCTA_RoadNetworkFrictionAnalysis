%%%%%%%%%% script_estimateAccelForSmoothTrafficTrajSCE_7DoFPPC.m %%%%%%%%%%
%% Purpose:
%   The pupose of this script is to estimate friction demand by letting a
%   7DOF vehicle model track the trajectory simulated by microscopic
%   traffic simulations in Aimsun.
%
% Author: Juliette Mitrovich, adapted from Satya Prasad
% Created: 2022/04/09
% Updated: 2023/02/11

%% Prepare the workspace
clear all %#ok<CLALL>
close all
clc

%% Add path to dependencies
addpath('./Datafiles'); % all .mat files
addpath('./Utilities')
addpath('./Utilities/DB Lib'); % all the functions and wrapper class
addpath('./Utilities/VD Lib');
addpath('./Utilities/VD Lib/Dualtrack');
addpath('./Utilities/Path Lib');
addpath('./Utilities/Circle Lib');
addpath('./Utilities/UTM Lib');
addpath('./Utilities/MinMaxMean')

% Global variables for the vehicle model
% this needs to be changed to pass through all functions
global flag_update global_acceleration

%% Add necessary .mat files to the workspace
load A.mat % geotiff file used to add elevation to coordinates
load sections_shape.mat

%% Define inputs and parameters
% Database (DB) parameters that will NOT change
dbInput.ip_address = '130.203.223.234'; % Ip address of server host
dbInput.port       = '5432'; % port number
dbInput.username   = 'brennan'; % user name for the server
dbInput.password   = 'ivsg@Reber320'; % password
dbInput.db_name    = 'roi_db'; % database name
dbInput.trip_id    = 16; % traffic simulation id

% DB parameters that will change
dbInput.traffic_table = 'enu_reference_roi_db';

% flag triggers
flag.dbQuery  = false; % set to 'true' to query from the database
flag.dbQuerySectionID_VehID = false;
flag.doDebug  = false; % set to 'true' to print trajectory information to command window
flag.plot     = false; % set to 'true' to plot
flag.dbInsert = true; % set to 'true' to insert data to database

deltaT           = 0.001; % Vehicle simulation step-size
aimsun_step_size = 0.1; % Microscopic simulation step-size

trajectory_data = [];
cut_off_length = 20; % how much data to cut off the trajectory

%% Define vehicle and controller properties
% Define a MATLAB structure that specifies the physical values for a vehicle.
% For convenience, we ask that you call this stucture 'vehicle'.
vehicle.m   = 1600; % mass (kg)
vehicle.Izz = 2500; % mass moment of inertia (kg m^2)
vehicle.Iw  = 1.2; % mass moment of inertia of a wheel (kg m^2)
vehicle.Re  = 0.32; % effective radius of a wheel (m)
vehicle.a   = 1.3; % length from front axle to CG (m)
vehicle.L   = 2.6; % wheelbase (m)
vehicle.b   = 1.3; % length from rear axle to CG (m)
vehicle.d   = 1.5; % track width (m)
vehicle.h_cg = 0.42; % height of the cg (m)
vehicle.Ca  = [95000; 95000; 110000; 110000]; % wheel cornering stiffnesses
vehicle.Cx  = [65000; 65000; 65000; 65000]; % longitudinal stiffnesses

vehicle.contact_patch_length = 0.15; % [meters]
vehicle.friction_ratio       = 1; % [No units]

controller.look_ahead_distance = 10; % look-ahead distance [meters]
controller.steering_Pgain      = 0.1; % P gain for steering control
controller.velocity_Pgain      = 350; % P gain for steering control

% Parameters and initial conditions for simulink and matlab model
road_properties.grade = 0;
road_properties.bank_angle = 0; % road properties
friction_coefficient  = 1.0*ones(4,1);

%% Define load transfer conditions
vdParam.longitudinalTransfer = 1;
if vdParam.longitudinalTransfer
    vdParam.lateralTransfer = 1;
    type_of_transfer = 'both';
else
    vdParam.lateralTransfer = 0;
    type_of_transfer = 'default';
end

%% Get the current UTC and GPS time
gps_utc_time = 18; % [seconds] Difference between GPS and UTC time
matsim_unix_time = posixtime(datetime('now','TimeZone','America/New_York')); % [seconds] UTC Time
matsim_gps_time  = matsim_unix_time+gps_utc_time; % [seconds] GPS Time

%% Query and store ENU reference data
% Set coordinates of local origin for converting LLA to ENU
lat0 = 40.79365087;
lon0 = -77.86460284;
h0 = 334.719;
wgs84 = wgs84Ellipsoid;

%% Create an elevation map and convert lat and lon coordinates to UTM
% the elevation map will be used to add elevation to the road centerline
% and the trajectories
% [X,Y,elevation_map] = fcn_createElevationMapAndConvertLL2UTM(A);
load SCE_geotiff_X.mat
load SCE_geotiff_Y.mat
load SCE_geotiff_elevation_map.mat

%% Get the road centerline  data from AIMSUN shape file
% centerline data for road SECTIONS
% [sectionID number_of_lanes X Y]
RT_RCL_section_UTM = fcn_calculateRoadCenterlineSection(sections_shape);

% centerline data for road JUNCTIONS
% road_centerline_junction = fcn_calculateRoadCenterlineTurning(turning_shape);
%% Convert road centerline position from UTM to ENU
RT_RCL_path_all = RT_RCL_section_UTM(:,[3,4]);

[RT_RCL_cg_east, RT_RCL_cg_north, RT_RCL_cg_up] = ...
    fcn_addElevationAndConvertUTM2ENU...
    (RT_RCL_path_all,X,Y,elevation_map,lat0,lon0,h0,wgs84);

sectionID = RT_RCL_section_UTM(:,1);
number_of_lanes = RT_RCL_section_UTM(:,2);
% concatinate needed RCL data
% [section ID, # of lanes, cg_east, cg_north, cg_up]
RT_RCL_sections_ENU = ...
    [sectionID number_of_lanes RT_RCL_cg_east RT_RCL_cg_north RT_RCL_cg_up];

%% Query for valid Section ID and Vehicle ID combinations
% set traffic table to collect vehicle trajectory data
dbInput.traffic_table = 'road_traffic_raw_extend_2'; % table containing traffic simulation data

if flag.dbQuerySectionID_VehID
    disp('Query for section and vehicle ID')
    SectionId_VehID    = fcn_findValidSectionandVehicleId(dbInput.trip_id,dbInput);
    list_of_vehicleIds = unique(SectionId_VehID(:,2));
    list_of_sectionIds = unique(SectionId_VehID(:,1));
else
    load SectionId_VehID.mat 
    list_of_vehicleIds = unique(SectionId_VehID(:,2));
    list_of_sectionIds = unique(SectionId_VehID(:,1));
end % NOTE: END IF statement 'flag.dbQuery'

%% Query for section ID vehicle trajectory
N_sectionID = length(list_of_sectionIds);
for index_sectionID = 1:N_sectionID
    % reset vehicle counter to 0
    vehicle_counter = 0;
    %% Initialize variable to store data
    if list_of_sectionIds(index_sectionID) > 0
        if flag.dbQuery
            disp('Query for section ID reference trajectory:')
            disp(index_sectionID)
            raw_trajectory = fcn_querySectionIdVehicleTrajectory(list_of_sectionIds(index_sectionID),...
                dbInput.trip_id,dbInput);
        end

        %% Add elevation to the State College road-network and convert to ENU
        RT_veh_path_all = raw_trajectory{:,{'position_front_x','position_front_y'}};

        [RT_veh_cg_east, RT_veh_cg_north, RT_veh_cg_up] = fcn_addElevationAndConvertUTM2ENU...
            (RT_veh_path_all,X,Y,elevation_map,lat0,lon0,h0,wgs84);

        % make sure the data calculated correctly
        if isempty(RT_veh_cg_east) == 0
            % change UTM coordinates in raw trajectory to new ENU
            %   coordinates
            raw_trajectory{:,{'position_front_x'}} = RT_veh_cg_east;
            raw_trajectory{:,{'position_front_y'}} = RT_veh_cg_north;

            %% Calculate lane centerline (LCL) from RCL for the specific section ID
            % Create the index to find the path coordinates for this
            %   section ID
            index_RCL_path = RT_RCL_sections_ENU(:,1) == list_of_sectionIds(index_sectionID);

            % calculate station of RCL path for 1 section ID
            RT_RCL_sectionID_ENU = RT_RCL_sections_ENU(index_RCL_path,:);
            RT_RCL_path = RT_RCL_sectionID_ENU(:,[3,4]);
            RT_RCL_diff_station = sqrt(sum(diff(RT_RCL_path).^2,2));
            RT_RCL_station = cumsum([0; RT_RCL_diff_station]);

            % create a reference traversal structure for the RCL path
            %   can change this to the fcn_create traversal from path
            RT_RCL_traversal.X = RT_RCL_sectionID_ENU(:,3); % x coordinate of RCL path
            RT_RCL_traversal.Y = RT_RCL_sectionID_ENU(:,4); % y coordinate of RCL path
            RT_RCL_traversal.Z = RT_RCL_sectionID_ENU(:,5); % z coordinate of RCL path
            RT_RCL_traversal.Station = RT_RCL_station; % station that was just calculated

            % Determine how many LCL need to be calculated based on the
            %   number of lanes in that section
            number_of_lanes_in_sectionID = unique(RT_RCL_sectionID_ENU(:,2));

            % Calculate the lane centerlines: [X, Y, Yaw, Station, lane #]
            [RT_LCL_lane1, RT_LCL_lane2, RT_LCL_lane3, RT_LCL_lane4, RT_LCL_XY_all] = ...
                fcn_calculateLaneCenterline(RT_RCL_traversal,number_of_lanes_in_sectionID);

            %% Redecimate the RCL stations at 1-meter increments and cut-off x-meters
            RT_RCL_new_stations_traversal = fcn_calculateNewStationsAndCutoffData...
                (RT_RCL_traversal,station_interval_RCL,cut_off_length);

            %% Run vehicle simulation
            % calculate how many vehicles drive on this section ID and loop
            % through those vehicles
            disp('Running Vehicle Simulation')

            vehicleIds_on_sectionId = unique(raw_trajectory{:,'vehicle_id'});
            vehicleIds_on_sectionId_length = length(vehicleIds_on_sectionId);

            % Evaluate 75 reference trajectories
            % If less than 75 vehicles drive on a section, evaluate all
            N_vehicles = 75;
            if N_vehicles > vehicleIds_on_sectionId_length
                N_vehicles = vehicleIds_on_sectionId_length;
            end

            % run the simulation for N_vehicles
            for index_vehicle = 1:N_vehicles
                %% calculate the trajectory for the index_vehicle
                indices_raw_path = raw_trajectory{:,'vehicle_id'} == vehicleIds_on_sectionId(index_vehicle);
                RT_veh_path = raw_trajectory{indices_raw_path,...
                    {'position_front_x','position_front_y'}};
                RT_veh_raw_trajectory = raw_trajectory(indices_raw_path,:);

                % store lane number indication to check for LC
                RT_veh_lanes = RT_veh_raw_trajectory{:,'lane_number'};

                RT_veh_path_min_length = length(RT_veh_path(:,1));

                if RT_veh_path_min_length > 1

                    % check if there's a lane change
                    isLanechange = find(all(~diff(RT_veh_lanes)));
                    if isempty(isLanechange) == 0

                        RT_veh_diff_station = sqrt(sum(diff(RT_veh_path).^2,2));
                        if 0 == RT_veh_diff_station(1)
                            RT_veh_station = cumsum([0; RT_veh_diff_station(2:end)]);
                            RT_veh_diff_station    = [RT_veh_diff_station(2:end); RT_veh_diff_station(end)];
                            RT_veh_raw_trajectory  = RT_veh_raw_trajectory(2:end,:);
                            RT_veh_path            = RT_veh_raw_trajectory{:,...
                                {'position_front_x','position_front_y'}};
                        else
                            RT_veh_station = cumsum([0; RT_veh_diff_station]);
                            RT_veh_diff_station    = [RT_veh_diff_station; RT_veh_diff_station(end)];  %#ok<AGROW>
                        end

                        RT_veh_min_station_length = RT_veh_station(end) - cut_off_length;

                        % check that you have enough data after 20m to simulate
                        if RT_veh_min_station_length >= 5
                            
                            % determine what lane the vehicle is driving on
                            lane_number = RT_veh_lanes(1);

                            % snap the RT onto the LCL and calculate yaw
                            RT_veh_path_length = length(RT_veh_path);
                            RT_veh_yaw = NaN(RT_veh_path_length,1);
                            for index_vehicle_path_point = 1:RT_veh_path_length
                                % figure out what lane corresponds to the index point
                                %   thats the traversal input
                                RT_veh_path_point = RT_veh_path(index_vehicle_path_point,[1,2]);
                                % lane_number = closest_lane_number(index_vehicle_path_point_yaw);
                                if lane_number == 1
                                    traversal = RT_LCL_lane1;
                                elseif lane_number == 2
                                    traversal = RT_LCL_lane2;
                                elseif lane_number == 3
                                    traversal = RT_LCL_lane3;
                                elseif lane_number == 4
                                    traversal = RT_LCL_lane4;
                                end

                                [~,~,path_point_yaw,~,~,~] = ...
                                    fcn_Path_snapPointOntoNearestTraversal(RT_veh_path_point, traversal);

                                RT_veh_yaw(index_vehicle_path_point) = path_point_yaw;
                            end

                            %% Calcuate the start stop trajectory (if any)
                            % Indices where the vehicle stopped
                            temp_var         = (1:size(RT_veh_path,1))';
                            % Indices at which the vehicle is at rest
                            indices_to_rest  = temp_var(RT_veh_diff_station==0);
                            % Indices at which the vehicle begins to stop
                            % so indices to start becomes 1, indeces to stop becomes last
                            % index (size of trajectory)
                            if length(indices_to_rest) < 1
                                indices_to_stop = length(RT_veh_path(:,1));
                                indices_to_start = 1;
                            else
                                indices_to_stop  = indices_to_rest([true; 1~=diff(indices_to_rest)]);
                                % Indices at which the vehicle begins to move
                                indices_to_start = [1; indices_to_rest([1~=diff(indices_to_rest); false])+1];
                                % Total number of times a vehicle is stoping
                            end
                            min_trip_size = 1;
                            %% Process a vehicle trajectory between a start and stop
                            for index_stop = 1

                                RT_veh_start_stop_trajectory = RT_veh_raw_trajectory(indices_to_start(index_stop):...
                                    indices_to_stop(index_stop),:);

                                if size(RT_veh_start_stop_trajectory,1) > min_trip_size
                                    % Initial conditions
                                    global_acceleration = zeros(7,1); % global indicates that it's a global variable
                                    input_states = [RT_veh_start_stop_trajectory.current_speed(1); 0; 0; ...
                                        RT_veh_start_stop_trajectory.current_speed(1)*ones(4,1)/vehicle.Re; ...
                                        RT_veh_start_stop_trajectory.position_front_x(1); ...
                                        RT_veh_start_stop_trajectory.position_front_y(1); ...
                                        RT_veh_yaw(indices_to_start(index_stop))];
                                    U = input_states(1);

                                    % Reference traversal for the vehicle to track
                                    RT_veh_sim.X   = RT_veh_start_stop_trajectory.position_front_x;
                                    RT_veh_sim.Y   = RT_veh_start_stop_trajectory.position_front_y;
                                    RT_veh_sim.Yaw = RT_veh_yaw(indices_to_start:...
                                        indices_to_stop);
                                    RT_veh_sim.Station  = RT_veh_station(indices_to_start:...
                                        indices_to_stop);
                                    RT_veh_sim.Velocity = RT_veh_start_stop_trajectory.current_speed;

                                    % Time parameters
                                    % Note: TotalTime is the time taken in Aimsun, could add a slack to this
                                    total_time_matrix = RT_veh_raw_trajectory.aimsun_time;
                                    total_time = RT_veh_raw_trajectory.aimsun_time(indices_to_stop(index_stop))-...
                                        RT_veh_raw_trajectory.aimsun_time(indices_to_start(index_stop));
                                    % check to make sure time doesn't increase
                                    %   by more than 0.1s
                                    total_time_check_index = diff(total_time_matrix);
                                    total_time_check = find(diff(total_time_check_index) > 0.1);
                                    if isempty(total_time_check) == 1
                                        % Duration where vehicle is at rest
                                        if index_stop ~= index_stop
                                            duration_of_rest = RT_veh.aimsun_time(indices_to_stop(index_stop))-...
                                                RT_veh.aimsun_time(indices_to_start(index_stop+1));
                                        else
                                            duration_of_rest = 0;
                                        end
                                        % Define variable to store veh sim information
                                        t_vector = 0:deltaT:total_time;
                                        N_timesteps = length(t_vector); % calculate # of time steps sim needs to run
                                        matlab_time   = NaN(N_timesteps,1);
                                        matlab_States = NaN(N_timesteps,9);
                                        matlab_pose   = NaN(N_timesteps,3);

                                        tire_forces_fl_sq = NaN(N_timesteps,1);
                                        tire_forces_fr_sq = NaN(N_timesteps,1);
                                        tire_forces_rl_sq = NaN(N_timesteps,1);
                                        tire_forces_rr_sq = NaN(N_timesteps,1);

                                        normal_force_fl = NaN(N_timesteps,1);
                                        normal_force_fr = NaN(N_timesteps,1);
                                        normal_force_rl = NaN(N_timesteps,1);
                                        normal_force_rr = NaN(N_timesteps,1);

                                        for ith_time = 1:N_timesteps
                                            t = t_vector(ith_time);
                                            matlab_time(ith_time)       = t;
                                            matlab_States(ith_time,1:7) = input_states(1:7)';
                                            matlab_pose(ith_time,:)     = input_states(8:10)';

                                            %% Controller: Steering + Velocity
                                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                            % Note: Controller need to be tuned, particularly for the
                                            % velocity
                                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                            % add if statement with total time to set target_U = 0
                                            pose = matlab_pose(ith_time,:)';
                                            [target_lookAhead_pose,target_U] = ...
                                                fcn_VD_snapLookAheadPoseOnToTraversal(pose,RT_veh_sim,controller);
                                            steering_angle = fcn_VD_lookAheadLatController(pose,target_lookAhead_pose,...
                                                controller);
                                            if 0<=U
                                                wheel_torque = fcn_VD_velocityController(U,target_U,controller);
                                            else
                                                wheel_torque = zeros(4,1);
                                            end

                                            %% 7-DoF Vehicle Model
                                            flag_update = true; % set it to to true before every call to RK4 method
                                            if 0.5<=U
                                                [~,y] = fcn_VD_RungeKutta(@(t,y) fcn_VD_dt7dofModelForController(t,y,...
                                                    steering_angle,wheel_torque,...
                                                    vehicle,road_properties,friction_coefficient,type_of_transfer),...
                                                    input_states,t,deltaT);
                                                U = y(1); V = y(2); r = y(3); omega = y(4:7);
                                                [~,normal_force, tire_forces] = fcn_VD_dt7dofModelForController(t,y,...
                                                    steering_angle,wheel_torque,...
                                                    vehicle,road_properties,friction_coefficient,type_of_transfer);
                                                input_states = y; clear y;
                                            elseif 0<=U
                                                kinematic_input_states = [input_states(1); input_states(8:10)];
                                                [~,y] = fcn_VD_RungeKutta(@(t,y) fcn_VD_dtKinematicModelForController(t,y,...
                                                    steering_angle,wheel_torque,...
                                                    vehicle,road_properties,type_of_transfer),...
                                                    kinematic_input_states,t,deltaT);
                                                U = y(1); V = 0; omega = (U/vehicle.Re)*ones(4,1);
                                                r = fcn_VD_kinematicYawRate(U,steering_angle,vehicle);
                                                input_states = [U; V; r; omega; y(2:4)]; clear y;
                                            end
                                            % store tire forces squared
                                            tire_forces_fl_sq(ith_time) = tire_forces(1,1)^2 + tire_forces(1,2)^2;
                                            tire_forces_fr_sq(ith_time) = tire_forces(2,1)^2 + tire_forces(2,2)^2;
                                            tire_forces_rl_sq(ith_time) = tire_forces(3,1)^2 + tire_forces(3,2)^2;
                                            tire_forces_rr_sq(ith_time) = tire_forces(4,1)^2 + tire_forces(4,2)^2;

                                            % store normal force
                                            normal_force_fl(ith_time) = normal_force(1,1);
                                            normal_force_fr(ith_time) = normal_force(2,1);
                                            normal_force_rl(ith_time) = normal_force(3,1);
                                            normal_force_rr(ith_time) = normal_force(4,1);

                                            matlab_States(ith_time,8:9) = global_acceleration(1:2)';
                                        end % NOTE: END FOR loop for vehicle controller and model

                                        normal_forces = [normal_force_fl normal_force_fr...
                                            normal_force_rl normal_force_rr];
                                        tire_forces_sq = [tire_forces_fl_sq tire_forces_fr_sq...
                                            tire_forces_rl_sq tire_forces_rr_sq];

                                        %% Snap and interpolate vehicle data to the road
                                        % snap vehicle trajectory onto the
                                        % new trajectory

                                        VT_veh_path = matlab_pose(:,[1,2]);
                                        VT_veh_traversal = fcn_Path_convertPathToTraversalStructure(VT_veh_path);


                                        % check the VT station length
                                        VT_veh_min_station_length = VT_veh_traversal.Station(end) - cut_off_length;

                                        if VT_veh_min_station_length >= 5

                                            vehicle_counter = vehicle_counter + 1;

                                            % cut off first 20 m of data
                                            rows_to_select_veh = find(VT_veh_traversal.Station >= cut_off_length);
                                            VT_veh_traversal.X = VT_veh_traversal.X(rows_to_select_veh);
                                            VT_veh_traversal.Y = VT_veh_traversal.Y(rows_to_select_veh);
                                            VT_veh_traversal.Z = VT_veh_traversal.Z(rows_to_select_veh);
                                            VT_veh_traversal.Station = VT_veh_traversal.Station(rows_to_select_veh);

                                            normal_forces = normal_forces(rows_to_select_veh,:);
                                            tire_forces_sq = tire_forces_sq(rows_to_select_veh,:);
                                            
                                            [friction_demand_fl,...
                                                friction_demand_fr,...
                                                friction_demand_rl,...
                                                friction_demand_rr] = ...
                                                fcn_snapAndInterpolateFrictionDataToRoad...
                                                (RT_RCL_new_stations_traversal,VT_veh_traversal,normal_forces,tire_forces_sq);

                                            %% Put snapped vehicle into road data
                                            VT_new_stations_length = length(RT_RCL_new_stations_traversal.X);
                                            N = index_vehicle;
                                            % store the value

                                            if vehicle_counter == 1
                                                % for the first index, the friction
                                                %   is the min, max, and mean
                                                friction_fl_max = friction_demand_fl;
                                                friction_fr_max = friction_demand_fr;
                                                friction_rl_max = friction_demand_rl;
                                                friction_rr_max = friction_demand_rr;
                                                friction_fl_last_max = friction_demand_fl;
                                                friction_fr_last_max = friction_demand_fr;
                                                friction_rl_last_max = friction_demand_rl;
                                                friction_rr_last_max = friction_demand_rr;

                                                friction_fl_min = friction_demand_fl;
                                                friction_fr_min = friction_demand_fr;
                                                friction_rl_min = friction_demand_rl;
                                                friction_rr_min = friction_demand_rr;
                                                friction_fl_last_min = friction_demand_fl;
                                                friction_fr_last_min = friction_demand_fr;
                                                friction_rl_last_min = friction_demand_rl;
                                                friction_rr_last_min = friction_demand_rr;

                                                % store the first mean
                                                friction_fl_mean = friction_demand_fl;
                                                friction_fr_mean = friction_demand_fr;
                                                friction_rl_mean = friction_demand_rl;
                                                friction_rr_mean = friction_demand_rr;

                                            elseif vehicle_counter > 1
                                                % min, max, mean of FL tire
                                                [friction_fl_min, friction_fl_max,friction_fl_mean] = ...
                                                    fcn_findMinMaxMean(index_vehicle,friction_demand_fl, friction_fl_min, friction_fl_max, friction_fl_mean);
                                                
                                                % min, max, mean of FR tire
                                                [friction_fr_min, friction_fr_max,friction_fr_mean] = ...
                                                    fcn_findMinMaxMean(index_vehicle,friction_demand_fr, friction_fr_min, friction_fr_max, friction_fr_mean);

                                                % min, max, mean of RL tire
                                                [friction_rl_min, friction_rl_max,friction_rl_mean] = ...
                                                    fcn_findMinMaxMean(index_vehicle,friction_demand_rl, friction_rl_min, friction_rl_max, friction_rl_mean);

                                                % min, max, mean of RR tire
                                                [friction_rr_min, friction_rr_max,friction_rr_mean] = ...
                                                    fcn_findMinMaxMean(index_vehicle,friction_demand_rr, friction_rr_min, friction_rr_max, friction_rr_mean);
                                            end

                                            %% Plot the results
                                            if flag.plot
                                                cg_station = RT_RCL_new_stations_traversal.Station;

                                                fcn_VD_plotStationLongitudinalAcceleration(cg_station,lon_accel,01); % Plot longitudinal acceleration
                                                fcn_VD_plotStationLateralAcceleration(cg_station,lat_accel,02); % Plot lateral acceleration
                                                fcn_VD_plotStationLongitudinalVelocity(cg_station,lon_vel,03); % Plot longitudinal velocity
                                                fcn_VD_plotStationLateralVelocity(cg_station,lat_vel,04); % Plot lateral velocity
                                                fcn_VD_plotStationYawRate(cg_station,yaw_rate,05); % Plot yaw rate
                                                fcn_VD_plotTrajectory([VT_veh_traversal.X VT_veh_traversal.Y],06); % Plot output trajectory
                                                fcn_VD_plotStationYaw(cg_station,pose(:,3),07); % Plot yaw

                                                fcn_VD_plotStationFrictionDemand(cg_station,friction_demand_fl_total,08); % Plot force ratio
                                                fcn_VD_plotStationFrictionDemand(cg_station,friction_demand_fr_total,09); % Plot force ratio
                                                fcn_VD_plotStationFrictionDemand(cg_station,friction_demand_rl_total,10); % Plot force ratio
                                                fcn_VD_plotStationFrictionDemand(cg_station,friction_demand_rr_total,11); % Plot force ratio

                                                fcn_VD_plotStationFrictionDemand(cg_station,friction_demand,09)

                                            end % NOTE: END IF statement 'flag.plot'
                                        end % NOTE: END IF statement to check for min station length
                                    end % NOTE: END IF statment to check for timesteps
                                end % NOTE: END IF statement for minimum trip size
                            end % NOTE: END FOR loop for number of stops
                        end % NOTE: END IF statement for minimum length of vehicle trajectory
                    end % NOTE: END IF statement to check if a lane change occurs
                end % NOTE: END IF statment to check for minimum path length
            end % NOTE: END FOR loop of vehicles on sectionID
            %% Calculate variables to store
            % calculate station
            disp(vehicle_counter)

            cg_station = RT_RCL_new_stations_traversal.Station;

            output_data_length = length(cg_station);

            [cg_new,ia,~] = unique([RT_veh_cg_east,RT_veh_cg_north],'rows');
            RT_veh_cg_east_new = cg_new(:,1);
            RT_veh_cg_north_new = cg_new(:,2);
            RT_veh_cg_up_new = RT_veh_cg_up(ia);

            % Calculate ENU coordinates for RCL
            RCL_cg_east = RT_RCL_new_stations_traversal.X;
            RCL_cg_north = RT_RCL_new_stations_traversal.Y;
            RCL_cg_up = fcn_addElevationToPath([RCL_cg_east RCL_cg_north],RT_veh_cg_east_new,...
                RT_veh_cg_north_new,RT_veh_cg_up_new);
            
            %% Save data to variable in the workspace

            if vehicle_counter > 0
                % road segment information
                friction_measurement.road_segment_id = list_of_sectionIds(index_sectionID)*ones(output_data_length,1);

                % Station information
                friction_measurement.cg_station = cg_station;
               
                % Possible number of vehicles to simulate
                friction_measurement.vehicles_on_road = N_vehicles*ones(output_data_length,1);

                % Track the number of vehicles simulated
                friction_measurement.vehicles_simulated = vehicle_counter*ones(output_data_length,1);

                % ENU RCL coordinates
                friction_measurement.RCL_cg_east = RCL_cg_east;
                friction_measurement.RCL_cg_north = RCL_cg_north;
                friction_measurement.RCL_cg_up = RCL_cg_up;

                % Friction Demand
                friction_measurement.friction_fl_min = friction_fl_min;
                friction_measurement.friction_fr_min = friction_fr_min;
                friction_measurement.friction_rl_min = friction_rl_min;
                friction_measurement.friction_rr_min = friction_rr_min;

                friction_measurement.friction_fl_max = friction_fl_max;
                friction_measurement.friction_fr_max = friction_fr_max;
                friction_measurement.friction_rl_max = friction_rl_max;
                friction_measurement.friction_rr_max = friction_rr_max;

                friction_measurement.friction_fl_mean = friction_fl_mean;
                friction_measurement.friction_fr_mean = friction_fr_mean;
                friction_measurement.friction_rl_mean = friction_rl_mean;
                friction_measurement.friction_rr_mean = friction_rr_mean;

                % convert the struct format to table format
                friction_measurement_table = struct2table(friction_measurement);

                trajectory_data = [trajectory_data; friction_measurement_table];
            end
        end % NOTE: END IF statement to check that ENU for VT was calculated
    end % NOTE: END IF statement for section ID > 0 (only evaluate sections)
end % NOTE: END FOR loop for evaluating section ID trajectories