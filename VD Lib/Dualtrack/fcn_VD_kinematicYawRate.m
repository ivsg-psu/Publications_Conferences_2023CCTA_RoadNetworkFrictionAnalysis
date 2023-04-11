function yaw_rate = fcn_VD_kinematicYawRate(U,steering_angle,vehicle)

if 0~=mean(steering_angle(1:2))
    turn_radius = vehicle.d/mean(steering_angle(1:2));
    yaw_rate    = U/turn_radius;
else
    yaw_rate    = 0;
end

end