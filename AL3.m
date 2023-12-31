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
RIRs = RIRs;
actual_RIR = actual_RIR;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%------------------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compute the average energy of the collected RIRs
E_avg = mean(sum(RIRs.^2, 1));

% Apply weights to each RIR
distances = sqrt(sum((locations - target_location).^2, 2));
weights = exp(-distances / mean(distances));
WeightedRIRs = RIRs * diag(weights);


x0 = ones(20, 1) / 20;

% Objective function: L1 norm of x
objective = @(x) norm(x, 1);

% Non-linear constraint: energy of the RIR
nonlcon = @(x) deal([], sum(sum((WeightedRIRs.' * x).^2)) - E_avg);

% Optimization options
options = optimoptions('fmincon', 'Algorithm', 'sqp'); % Sequential Quadratic Programming

% Solving the problem using fmincon
[x_opt, fval, exitflag, output] = fmincon(objective, x0, [], [], [], [], [], [], nonlcon, options);

% Estimated RIR at the new location
estimated_RIR = WeightedRIRs * x_opt;


error = actual_RIR - estimated_RIR;
abs_error = norm(error, 2);

% Calculate the power of the signal and noise
signal_power = mean(actual_RIR.^2);
noise_power = mean(error.^2);

% Calculate SNR
snr_value = 10 * log10(signal_power / noise_power);

% Display the SNR
disp(['SNR = ', num2str(snr_value), ' dB']);

