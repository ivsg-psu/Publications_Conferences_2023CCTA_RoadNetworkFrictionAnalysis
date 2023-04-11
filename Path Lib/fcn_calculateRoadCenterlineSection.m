function road_centerline_section = fcn_calculateRoadCenterlineSection(sections_shape,varargin)
%%%%%%%%%%%%%% Function fcn_calculateRoadCenterlineSection %%%%%%%%%%%%%%
% Purpose:
%   fcn_calculateRoadCenterlineSection calculates the centerline of the
%   entire State College road network using the section.shp shape file of
%   the OSM road network. Each coordinate is associated with a section ID
%
% Format:
%   road_centerline_section = fcn_calculateRoadCenterlineSection...
%       (sections_shape)
%
% INPUTS:
%   sections_shape: sections.shp shape file from the OSM State College road
%       network
%
% OUTPUTS:
%   road_centerline_section: consists of...
%       associated road section ID
%       UTM x coordinate
%       UTM y coordinate
%
% Author: Juliette Mitrovich
% Created: 2022/12/21
% Updated: 2023/01/17

flag_do_plots = 0; % % Flag to plot the final results

%% Check for variable argument inputs (varargin)

% Does user want to show the plots?
if 2 == nargin
    temp = varargin{end};
    if ~isempty(temp) % Did the user NOT give an empty figure number?
        fig_num = temp;
        figure(fig_num);
        flag_do_plots = 1;
    end
else
    flag_do_plots = 0;
end


%% Extract ID values from shape file struct
SectionID_numberOfLanes = [(extractfield(sections_shape,'id'))',...
    (extractfield(sections_shape,'nb_lanes'))'];
X_pos = (extractfield(sections_shape,'X'))';
X_pos = X_pos(~isnan(X_pos),:);
posted_speed_limit = (extractfield(sections_shape,'speed'))';

%% get the centerline data for network
% initialize variable to store processed position orientation (pose) data
list_of_sectionIds = SectionID_numberOfLanes(:,1);
list_number_of_lanes = SectionID_numberOfLanes(:,2);

list_of_sectionIds_length = length(list_of_sectionIds);
X_pos_length = length(X_pos);

road_centerline_section = NaN(X_pos_length,5);
start_row = 1;

for i = 1:list_of_sectionIds_length
    % create the centerline path for each section ID
    centerline_path = [sections_shape(i).X', sections_shape(i).Y'];

    if flag_do_plots
        % if you want to plot the data, keep the NaN values
    else
        %         if not, clear NaN values from the data
        centerline_path = centerline_path(~isnan(centerline_path(:,1)),:);
    end

    centerline_path_length = length(centerline_path);
    end_row = start_row+centerline_path_length-1;

    % processed centerline data: section ID, path, yaw
    road_centerline_section(start_row:end_row,1) = list_of_sectionIds(i)*ones(numel(centerline_path(:,1)),1);
    road_centerline_section(start_row:end_row,2) = list_number_of_lanes(i)*ones(numel(centerline_path(:,1)),1);
    road_centerline_section(start_row:end_row,[3,4]) = centerline_path;
    road_centerline_section(start_row:end_row,5) = posted_speed_limit(i)*ones(numel(centerline_path(:,1)),1);

    start_row = start_row + centerline_path_length;
end

%% Plot the data?
if flag_do_plots
    % plot the final XY result
    figure(fig_num);
    hold on;
    
    % Plot the reference trajectory first
    plot(road_centerline_section(:,3),road_centerline_section(:,4),'b.');
    hold on
    plot(road_centerline_section(:,3),road_centerline_section(:,4),'k-');
    title('Road Centerline of the SCE Network in UTM Coordinates', 'Interpreter', 'latex', 'Fontsize', 13);
    xlabel('East [m]', 'Interpreter', 'latex', 'Fontsize', 13);
    ylabel('North [m]', 'Interpreter', 'latex', 'Fontsize', 13); 
    axis equal
    grid on
end
end
