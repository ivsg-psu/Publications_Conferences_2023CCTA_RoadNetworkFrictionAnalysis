function [LCL_lane1, LCL_lane2, LCL_lane3, LCL_lane4, LCL_XY_all] = ...
    fcn_calculateLaneCenterline(reference_traversal,number_of_lanes)
%%%%%%%%%%%%%% Function fcn_calculateLaneCenterline %%%%%%%%%%%%%%
% Purpose:
%   fcn_calculateLaneCenterline calculates the centerline of each lane in
%   a section ID. The number of lanes in the section determines the number
%   of offset calculations and the size of the offset
%
% Format:
%   [LCL_lane1, LCL_lane2, LCL_lane3, LCL_lane4] =
%       fcn_calculateLaneCenterline(reference_traversal,number_of_lanes)
%
% INPUTS:
%   reference_traversal: The RCL used as a reference for the offset. Must
%       be a struct with .X, .Y, .Z, .Station
%   number_of_lanes: The number of lanes in the section ID
%
% OUTPUTS: Nx5 arrays
%   LCL_lane1: The centerline for lane 1, the right-most lane
%   LCL_lane2: The centerline for lane 2
%   LCL_lane3: The centerline for lane 3
%   LCL_lane4: The centerline for lane 4
%
% Dependencies
%   fcn_calculateLaneCenterlineYaw
%   fcn_Path_fillOffsetTraversalsAboutTraversal

% Author: Juliette Mitrovich
% Created: 2023/01/19

% Determine how many LCL need to be calculated based on the
% number of lanes in that section
lane1 = 1;
lane2 = 2;
lane3 = 3;
lane4 = 4;

fig_num = 789;

% Initialize the lane path variables
LCL_lane1_path = []; LCL_lane2_path = [];
LCL_lane3_path = []; LCL_lane4_path = [];

% Initialize lane variables [X,Y,yaw,station,lane #]
LCL_lane1 = []; LCL_lane2 = []; LCL_lane3 = []; LCL_lane4 = [];
% set input variables for offset_traversal function

if number_of_lanes == 1
    % the RCL is the LCL, therefore no offset
    LCL_lane1_path = [reference_traversal.X...
        reference_traversal.Y];

    % Calculate the yaw for each LCL
    [LCL_lane1_yaw, LCL_lane2_yaw,LCL_lane3_yaw, LCL_lane4_yaw] = ...
        fcn_calculateLaneCenterlineYaw...
        (LCL_lane1_path, LCL_lane2_path,...
        LCL_lane3_path,LCL_lane4_path);

    % create lane 1 variable
    % [X, Y, Yaw, Station, lane #]
    LCL_lane1.X           = LCL_lane1_path(:,1);
    LCL_lane1.Y           = LCL_lane1_path(:,2);
    LCL_lane1.Yaw         = LCL_lane1_yaw;
    LCL_lane1.Station     = reference_traversal.Station;
    LCL_lane1.lane_number = lane1*ones(numel(reference_traversal.X),1);

    % create an LCL path variable with all LCL coordinates in one column
    LCL_XY_all = [LCL_lane1.X LCL_lane1.Y];

elseif number_of_lanes == 2
    % RCL is the dividing line between 2 lanes
    % offset by 1.5m in each direction
    offsets = [-1.5; 1.5];

    % Calculate the offset trajectories
    offset_traversals = ...
        fcn_Path_fillOffsetTraversalsAboutTraversal...
        (reference_traversal, offsets);

    % Create path variables for each LCL
    LCL_lane1_path = [offset_traversals.traversal{1,1}.X...
        offset_traversals.traversal{1,1}.Y];
    LCL_lane2_path = [offset_traversals.traversal{1,2}.X...
        offset_traversals.traversal{1,2}.Y];

    % Calculate the yaw for each LCL
    [LCL_lane1_yaw, LCL_lane2_yaw,LCL_lane3_yaw, LCL_lane4_yaw] = ...
        fcn_calculateLaneCenterlineYaw...
        (LCL_lane1_path, LCL_lane2_path,...
        LCL_lane3_path,LCL_lane4_path);

    % create lane variables: [X, Y, Yaw, Station, lane #]
    % Lane 1
    LCL_lane1.X           = LCL_lane1_path(:,1);
    LCL_lane1.Y           = LCL_lane1_path(:,2);
    LCL_lane1.Yaw         = LCL_lane1_yaw;
    LCL_lane1.Station     = offset_traversals.traversal{1,1}.Station;
    LCL_lane1.lane_number = lane1*ones(numel(offset_traversals.traversal{1,1}.X),1);

    % Lane 2
    LCL_lane2.X           = LCL_lane2_path(:,1);
    LCL_lane2.Y           = LCL_lane2_path(:,2);
    LCL_lane2.Yaw         = LCL_lane2_yaw;
    LCL_lane2.Station     = offset_traversals.traversal{1,2}.Station;
    LCL_lane2.lane_number = lane2*ones(numel(offset_traversals.traversal{1,2}.X),1);

    % create an LCL path variable with all LCL coordinates in one column
    LCL_XY_all = [LCL_lane1.X LCL_lane1.Y;...
        LCL_lane2.X LCL_lane2.Y];


elseif number_of_lanes == 3
    % RCL is the LCL of the middle lane
    % offset by 3m in each direction
    offsets = [-3; 3];

    % Calculate the offset trajectories
    offset_traversals = ...
        fcn_Path_fillOffsetTraversalsAboutTraversal...
        (reference_traversal, offsets);

    % Create path variables for each LCL
    LCL_lane1_path = [offset_traversals.traversal{1,1}.X...
        offset_traversals.traversal{1,1}.Y];
    LCL_lane2_path = [reference_traversal.X...
        reference_traversal.Y];
    LCL_lane3_path = [offset_traversals.traversal{1,2}.X...
        offset_traversals.traversal{1,2}.Y];

    % Calculate the yaw for each LCL
    [LCL_lane1_yaw, LCL_lane2_yaw,LCL_lane3_yaw, LCL_lane4_yaw] = ...
        fcn_calculateLaneCenterlineYaw...
        (LCL_lane1_path, LCL_lane2_path,...
        LCL_lane3_path,LCL_lane4_path);

    % create lane variables: [X, Y, Yaw, Station, lane #]
    % Lane 1
    LCL_lane1.X           = LCL_lane1_path(:,1);
    LCL_lane1.Y           = LCL_lane1_path(:,2);
    LCL_lane1.Yaw         = LCL_lane1_yaw;
    LCL_lane1.Station     = offset_traversals.traversal{1,1}.Station;
    LCL_lane1.lane_number = lane1*ones(numel(offset_traversals.traversal{1,1}.X),1);

    % Lane 2
    LCL_lane2.X           = LCL_lane2_path(:,1);
    LCL_lane2.Y           = LCL_lane2_path(:,2);
    LCL_lane2.Yaw         = LCL_lane2_yaw;
    LCL_lane2.Station     = reference_traversal.Station;
    LCL_lane2.lane_number = lane2*ones(numel(reference_traversal.X),1);

    % Lane 3
    LCL_lane3.X           = LCL_lane3_path(:,1);
    LCL_lane3.Y           = LCL_lane3_path(:,2);
    LCL_lane3.Yaw         = LCL_lane3_yaw;
    LCL_lane3.Station     = offset_traversals.traversal{1,2}.Station;
    LCL_lane3.lane_number = lane3*ones(numel(offset_traversals.traversal{1,2}.X),1);

    % create an LCL path variable with all LCL coordinates in one column
    LCL_XY_all = [LCL_lane1.X LCL_lane1.Y;...
        LCL_lane2.X LCL_lane2.Y;...
        LCL_lane3.X LCL_lane3.Y];

elseif number_of_lanes == 4
    % RCL is the dividing line with 2 lanes on each side
    % offset by 1.5m and 4.5m in each direction
    offsets = [-1.5; 1.5; -4.5; 4.5];

    % Calculate the offset trajectories
    offset_traversals = ...
        fcn_Path_fillOffsetTraversalsAboutTraversal...
        (reference_traversal, offsets,fig_num);

    % Create path variables for each LCL
    LCL_lane1_path = [offset_traversals.traversal{1,1}.X...
        offset_traversals.traversal{1,1}.Y];
    LCL_lane2_path = [offset_traversals.traversal{1,2}.X...
        offset_traversals.traversal{1,2}.Y];
    LCL_lane3_path = [offset_traversals.traversal{1,3}.X...
        offset_traversals.traversal{1,3}.Y];
    LCL_lane4_path = [offset_traversals.traversal{1,4}.X...
        offset_traversals.traversal{1,4}.Y];

    % Calculate the yaw for each LCL
    [LCL_lane1_yaw, LCL_lane2_yaw,LCL_lane3_yaw, LCL_lane4_yaw] = ...
        fcn_calculateLaneCenterlineYaw...
        (LCL_lane1_path, LCL_lane2_path,...
        LCL_lane3_path, LCL_lane4_path);

    % create lane variables: [X, Y, Yaw, Station, lane #]
    % Lane 1
    LCL_lane1.X           = LCL_lane1_path(:,1);
    LCL_lane1.Y           = LCL_lane1_path(:,2);
    LCL_lane1.Yaw         = LCL_lane1_yaw;
    LCL_lane1.Station     = offset_traversals.traversal{1,1}.Station;
    LCL_lane1.lane_number = lane1*ones(numel(offset_traversals.traversal{1,1}.X),1);

    % Lane 2
    LCL_lane2.X           = LCL_lane2_path(:,1);
    LCL_lane2.Y           = LCL_lane2_path(:,2);
    LCL_lane2.Yaw         = LCL_lane2_yaw;
    LCL_lane2.Station     = offset_traversals.traversal{1,2}.Station;
    LCL_lane2.lane_number = lane2*ones(numel(offset_traversals.traversal{1,2}.X),1);

    % Lane 3
    LCL_lane3.X           = LCL_lane3_path(:,1);
    LCL_lane3.Y           = LCL_lane3_path(:,2);
    LCL_lane3.Yaw         = LCL_lane3_yaw;
    LCL_lane3.Station     = offset_traversals.traversal{1,3}.Station;
    LCL_lane3.lane_number = lane3*ones(numel(offset_traversals.traversal{1,3}.X),1);

    % Lane 4
    LCL_lane4.X           = LCL_lane4_path(:,1);
    LCL_lane4.Y           = LCL_lane4_path(:,2);
    LCL_lane4.Yaw         = LCL_lane4_yaw;
    LCL_lane4.Station     = offset_traversals.traversal{1,4}.Station;
    LCL_lane4.lane_number = lane4*ones(numel(offset_traversals.traversal{1,4}.X),1);

    % create an LCL path variable with all LCL coordinates in one column
    LCL_XY_all = [LCL_lane1.X LCL_lane1.Y;...
        LCL_lane2.X LCL_lane2.Y;...
        LCL_lane3.X LCL_lane3.Y;...
        LCL_lane4.X LCL_lane4.Y];

end
end