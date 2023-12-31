

data_sim = load("siml.mat");
data_real = load("data_matrix_real.mat");
coordinates = data_sim.receiverCoords;
impulse_responses_sim = data_sim.RIRS;
impulse_responses_real = data_real.soundData(1:20,:);

% We want to formulate the problem as an optimization setting. Try multiple
% algorithms

% Some prelimenaries:
rows = @(x) size(x,1); 
cols = @(x) size(x,2);

m = rows(impulse_responses_real);   % Number of RIRs (measurements)
n = cols(impulse_responses_real); % Size of the signal (adjust as per data size)

RIRs = impulse_responses_real; % Replace with actual RIRs (2000 samples each)
target_location = [2.900 1.290 0.001]; % Replace with the new location
actual_RIR = data_real.soundData(21,:);
y = RIRs.';
actual_RIR = actual_RIR.';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%------------------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Assuming you have the spatial coordinates for y and x

% Initialize phi for just the target RIR
phi_target = zeros(n, 20);

% Constructing phi for the target location
for j = 1:size(y, 2) % Loop over each RIR in y
    distance = norm(y_coords(j, :) - target_location);
    z = linspace(-10, 10, n); % Time axis for sinc
    phi_target(:, j) = sinc(z - distance);
end

% Interpolate to estimate the target RIR
target_RIR = zeros(n, 1);
for j = 1:size(y, 2)
    target_RIR = target_RIR + phi_target(:, j) .* y(:, j);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%---------------------------------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Estimated RIR at the new location
estimated_RIR = target_RIR;

error = actual_RIR - estimated_RIR;
abs_error = norm(error, 2);

% Calculate the power of the signal and noise
signal_power = mean(actual_RIR.^2);
noise_power = mean(error.^2);

% Calculate SNR
snr_value = 10 * log10(signal_power / noise_power);

% Display the SNR
disp(['SNR = ', num2str(snr_value), ' dB']);