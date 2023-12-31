data_sim = load("siml.mat");
data_real = load("data_matrix_real.mat");
impulse_responses_sim = data_sim.RIRs;
locations = data_sim.locations;
impulse_responses_real = data_real.soundData(1:20,:);

% We want to formulate the problem as an optimization setting. Try multiple
% algorithms

% Some prelimenaries:
rows = @(x) size(x,1); 
cols = @(x) size(x,2);

m = rows(impulse_responses_sim);   % Number of RIRs (measurements)
n = cols(impulse_responses_sim); % Size of the signal (adjust as per data size)

RIRs = impulse_responses_sim; % Replace with actual RIRs (2000 samples each)
target_location = locations(22, :); % Replace with the new location
actual_RIR = RIRs(:,22);
RIRs(:, 22) = [];
locations(22, :) = [];
y_coords = locations;
y = RIRs.';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%------------------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compute the average energy of the collected RIRs
E_avg = mean(sum(RIRs.^2, 1));

% Apply weights to each RIR
sigma = 1; % As previously discussed
w_distance = exp(-sum((locations - target_location).^2, 2) / (2 * sigma^2));
w_acoustic = arrayfun(@(i) corr(RIRs(:, i), actual_RIR), 1:size(RIRs, 2));

weights = w_distance .* w_acoustic;
weights = weights / sum(weights); % Normalize the weights
WeightedRIRs = RIRs * diag(weights);
delta = 0.0001;
lambda = 0.5;
desired_norm = sqrt(E_avg);


% Solving the Optimization Problem with Spatial Weights and Energy Constraint
cvx_begin
    variable x(2000)
    % Objective: L1-norm for sparsity and absolute difference for energy matching
    minimize(norm(x, 1))
    subject to 
        abs(norm(x, 2) - desired_norm) <= 0.00000000000001
cvx_end

% Estimated RIR at the new location
estimated_RIR = x;


error = actual_RIR - estimated_RIR;
abs_error = norm(error, 2);

% Calculate the power of the signal and noise
signal_power = mean(actual_RIR.^2);
noise_power = mean(error.^2);

% Calculate SNR
snr_value = 10 * log10(signal_power / noise_power);

% Display the SNR
disp(['SNR = ', num2str(snr_value), ' dB']);

