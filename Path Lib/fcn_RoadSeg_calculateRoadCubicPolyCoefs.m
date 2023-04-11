function [a,b,c,d] = fcn_RoadSeg_calculateRoadCubicPolyCoefs(t0,tf,s0,sf)

% Calculate a distance traveled along the path (s-coordinate) within the
% range of the cubic polynomial
ds = sf-s0;

% Set up the linear equalities to represent the start offset
% (t-coordinate), the end offset, and the covered distance along the path
% (s-coordinate)
A = [1 0 0 0; 1 ds ds^2 ds^3; 0 1 0 0; 0 1 2*ds 3*ds^2];
b = [t0; tf; 0; 0];

% Calculate the coefficients based on the linear equality constraint
x = A\b;

% Parse out the individual coefficients for return arguments
a = x(1);
b = x(2);
c = x(3);
d = x(4);