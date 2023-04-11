function [friction_demand_fl,friction_demand_fr,friction_demand_rl,friction_demand_rr] = ...
    fcn_snapAndInterpolateFrictionDataToRoad(new_stations_traj, old_stations_traj,normal_forces,tire_forces_sq)

% break out the normal and tire force variables
% store normal force
normal_force_fl = normal_forces(:,1);
normal_force_fr = normal_forces(:,2);
normal_force_rl = normal_forces(:,3);
normal_force_rr = normal_forces(:,4);

% store squares tire forces
tire_forces_fl_sq = tire_forces_sq(:,1);
tire_forces_fr_sq = tire_forces_sq(:,2);
tire_forces_rl_sq = tire_forces_sq(:,3);
tire_forces_rr_sq = tire_forces_sq(:,4);

new_stations_length = length(new_stations_traj.X);
first_path_point_vec = NaN(new_stations_length,1);
second_path_point_vec = NaN(new_stations_length,1);
percent_along_length_vec = NaN(new_stations_length,1);

for index_stations = 1:new_stations_length
    new_stations_path_point = [new_stations_traj.X(index_stations) ...
        new_stations_traj.Y(index_stations)];

    [~,~,~,first_path_point_index,...
        second_path_point_index,...
        percent_along_length] = ...
        fcn_Path_snapPointOntoNearestTraversal(new_stations_path_point, old_stations_traj);
   
    first_path_point_vec(index_stations) = first_path_point_index;
    second_path_point_vec(index_stations) = second_path_point_index;
    percent_along_length_vec(index_stations) = percent_along_length;
end

% Interpolate the friction data
friction_demand_fl = sqrt(tire_forces_fl_sq)./normal_force_fl;
friction_demand_fr = sqrt(tire_forces_fr_sq)./normal_force_fr;
friction_demand_rl = sqrt(tire_forces_rl_sq)./normal_force_rl;
friction_demand_rr = sqrt(tire_forces_rr_sq)./normal_force_rr;

friction_demand_fl = friction_demand_fl(first_path_point_vec) + ...
    (friction_demand_fl(second_path_point_vec) - friction_demand_fl(first_path_point_vec)).*percent_along_length_vec;
friction_demand_fr = friction_demand_fr(first_path_point_vec) + ...
    (friction_demand_fr(second_path_point_vec) - friction_demand_fr(first_path_point_vec)).*percent_along_length_vec;
friction_demand_rl = friction_demand_rl(first_path_point_vec) + ...
    (friction_demand_rl(second_path_point_vec) - friction_demand_rl(first_path_point_vec)).*percent_along_length_vec;
friction_demand_rr = friction_demand_rr(first_path_point_vec) + ...
    (friction_demand_rr(second_path_point_vec) - friction_demand_rr(first_path_point_vec)) .*percent_along_length_vec;

end