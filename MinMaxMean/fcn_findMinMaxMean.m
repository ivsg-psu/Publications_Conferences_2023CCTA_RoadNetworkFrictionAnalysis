function [min_vector, max_vector,mean_vector] = ...
    fcn_findMinMaxMean(N,new_vector, old_min_vector, old_max_vector,old_mean_vector)
min_vector = min([new_vector,old_min_vector],[],2);
max_vector = max([new_vector,old_max_vector],[],2);
mean_vector = ((N-1)/N)*old_mean_vector + (1/N)*new_vector;
end % Ends fcn_findMinMaxMean
