%%%%%%%%%%%%%%%%%%% Function fcn_querySectionIdVehicleTrajectory %%%%%%%%%%%%%%%%%%%
% Purpose:
%   fcn_querySectionIdVehicleTrajectory queries a vehicle's trajectory uniquely 
%   identified by 'section_id' in trip 'trip_id'.
% 
%   This code is a modified version of fcn_queryVehicleTrajectory
%
% Format:
%   vehicle_trajectory = fcn_querySectionIdVehicleTrajectory(section_id,trip_id,dbInput)
% 
% INPUTS:
%   section_id: ID of the vehicle. A positive integer.
%   trip_id: Id of a trip. A positive integer.
%   dbInput: It's a structure containing name of the database and tables.
% 
% OUTPUTS:
%   querySectionIdVehicleTrajectory: Contains all the attributes defined by 
%   'trajectory_attributes' sorted in the order of aimsun_time. 
%   It's a Nx17 table.
% 
% Author:  Satya Prasad, Juliette Mitrovich
% Created: 2023-01-17

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vehicle_trajectory = fcn_querySectionIdVehicleTrajectory(section_id,trip_id,dbInput)
trajectory_attributes = ['trips_id, vehicle_id, '...
                         'section_id, junction_id, lane_number, direction, '...
                         'position_front_x, position_front_y, position_front_z, '...
                         'latitude_front, longitude_front, '...
                         'station_total, current_speed, '...
                         'aimsun_time, system_entrance_time']; % attributes in the vehicle trajectory
% deleted current_pos because I don't collect it
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
% Are there right number of inputs?
if 3~=nargin
    error('fcn_queryVehicleTrajectory: Incorrect number of input arguments.')
end

% Check the size and validity of vehicle_id
if ~isnumeric(section_id) || 1~=numel(section_id) || any(0>=section_id) || ...
        any(section_id~=round(section_id))
    % display an error message if 'vehicle_id' is not a positive integer
    error('vehicle_id must be a POSITIVE INTEGER')
end

% Check the size and validity of trip_id
if ~isnumeric(trip_id) || 1~=numel(trip_id) || any(0>=trip_id) || ...
        any(trip_id~=round(trip_id))
    % display an error message if 'trip_id' is not a positive integer
    error('trip_id must be a POSITIVE INTEGER')
end

%% Query vehicle trajectory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   __  __       _       
%  |  \/  |     (_)      
%  | \  / | __ _ _ _ __  
%  | |\/| |/ _` | | '_ \ 
%  | |  | | (_| | | | | |
%  |_|  |_|\__,_|_|_| |_|
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% connect to the database
DB = Database(dbInput.db_name,dbInput.ip_address,dbInput.port,...
              dbInput.username,dbInput.password);

% SQL statement to query vehicle trajectory
traj_query = ['SELECT ' trajectory_attributes...
             ' FROM ' dbInput.traffic_table...
             ' WHERE section_id = ' num2str(section_id)...
               ' AND trips_id = ' num2str(trip_id)...
                   ' ORDER BY aimsun_time'];

% query trajectory data from the DB
vehicle_trajectory = fetch(DB.db_connection, traj_query);

% Disconnect from the database
DB.disconnect();
end