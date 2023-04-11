%%%%%%%%%%%%%%%% Function fcn_findValidSectionandVehicleId %%%%%%%%%%%%%%%%
% Purpose:
%   fcn_findValidSectionandVehicleId queries for unique 
%   (section_id, vehicle_id) combinations in a trip.
% 
% Format:
%   [SectionId_VehID,list_of_sections] = ...
%   fcn_findValidSectionandVehicleId(trip_id,dbInput)
% 
% INPUTS:
%   trip_id: Trip ID.
%   dbInput: It's a structure containing name of the database and tables.
% 
% OUTPUTS:
%   SectionId_VehID: It's a Mx2 vector. It consists of unique
%   (section_id, vehicle_id) pairs.
% 
% Author:  Satya Prasad
% Created: 2022-03-28
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SectionId_VehID = fcn_findValidSectionandVehicleId(trip_id,dbInput)
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
if 2~=nargin
    error('fcn_findValidVehicleIdandSectionId: Incorrect number of input arguments');
end

%% Query for valid Vehicle ID and Section ID combinations
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

% SQL query to grab section_id and vehicle_id
sql_query = ['SELECT DISTINCT section_id, vehicle_id'...
            ' FROM ' dbInput.traffic_table...
            ' WHERE trips_id =  ' num2str(trip_id)];

% grab section_id and vehicle_id
result = fetch(DB.db_connection,sql_query);
% convert the result from table to array containing
% unique (section_id, vehicle_id) pairs
SectionId_VehID = table2array(result);

% Disconnect from the database
DB.disconnect();
end