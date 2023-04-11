% script_test_fcn_findMinMaxMean
% Tests: fcn_findMinMaxMean
% Written by sbrennan@psu.edu

min_vector = inf(5,1);
max_vector = -inf(5,1);
mean_vector = rand(size(min_vector));
N_iterations = 300;

figure(12323)
clf;
hold on;
grid on;
axis([0 N_iterations+1 -0.5 1.5]);

for ith_iteration = 1:N_iterations
    raw_data = rand(size(min_vector)); % Create some dummy data
    [min_vector, max_vector,mean_vector] = fcn_findMinMaxMean(ith_iteration,raw_data, min_vector, max_vector, mean_vector);
    
    % plot results
    plot(ith_iteration,min_vector,'r.');
    plot(ith_iteration,max_vector,'g.');
    plot(ith_iteration,mean_vector,'b.');
    

end