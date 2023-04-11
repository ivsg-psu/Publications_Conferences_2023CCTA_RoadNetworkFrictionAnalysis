function dUdt = fcn_VD_longitudinalModel(normal_force,wheel_torque,vehicle,...
                                         road_properties)

g = 9.81; % [m/s^2]
dUdt = sum(wheel_torque/vehicle.Re-0.0*normal_force)/vehicle.m-...
       g*cos(road_properties.bank_angle)*sin(road_properties.grade);

end