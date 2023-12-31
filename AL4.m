
data_sim = load("data_matrix.mat");
data_real = load("data_matrix_real.mat");
coordinates = data_sim.receiverCoords;
impulse_responses_sim = data_sim.all_impulse_responses(1:20,:);
impulse_responses_real = data_real.soundData(1:20,:);

% We want to formulate the problem as an optimization setting. Try multiple
% algorithms

% Some prelimenaries:
rows = @(x) size(x,1); 
cols = @(x) size(x,2);

m = rows(impulse_responses_real);   % Number of RIRs (measurements)
n = cols(impulse_responses_real); % Size of the signal (adjust as per data size)

y_coords = [[1.330 1.050 0.535];
             [1.375 1.275 0.535];
             [1.370 1.550 0.535];
             [3.045 1.805 0.535];
             [3.255 2.145 0.535];
             [2.050 2.285 0.535];
             [1.800 0.850 0.630];
             [1.985 1.180 0.630];
             [2.005 1.470 0.630];
             [2.635 1.420 0.630];
             [2.740 1.745 0.630];
             [3.170 2.345 0.630];
             [2.310 0.940 0.010];
             [2.410 1.230 0.010];
             [2.410 1.420 0.010];
             [2.140 1.660 0.010];
             [1.395 2.170 0.010];
             [1.495 2.475 0.010];
             [2.890 0.790 0.001];
             [2.910 1.100 0.001]
            ];
RIRs = impulse_responses_real; % Replace with actual RIRs (2000 samples each)
target_location = [2.900 1.290 0.001]; % Replace with the new location
actual_RIR = data_real.soundData(21,:);
y = RIRs.';
actual_RIR = actual_RIR.';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%------------------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Assuming you have the spatial coordinates for y and x
x_coords = zeros([10000 3]);

for i = 1:10000
    for j = 1:3
        if j == 1
            x_coords(i, j) = 0 + (3.9-0)*rand();
        elseif j == 2
            x_coords(i, j) = 0 + (2.85-0)*rand();
        else
            x_coords(i, j) = 0 + (2.9-0)*rand();
        end
    end
end

x_coords(1, :) = target_location;

phi = zeros(n, 10000, 20);

% Constructing phi with sinc interpolation
for i = 1:size(y_coords, 1)
    for j = 1:size(x_coords, 1)
        distance = norm(y_coords(i,:) - x_coords(j,:));
        % Time axis for sinc - this would depend on the specifics of your RIR sampling
        t = linspace(-5, 5, n); 
        phi(:,j,i) = sinc(t - distance);
    end
end

% Interpolating y to estimate x
x = zeros(n, 10000);
for i = 1:size(y, 1)
    for j = 1:size(x, 2)
        x(:,j) = x(:,j) + phi(i,j,:) .* y(i);
    end
end

% Estimated RIR at the new location
estimated_RIR = x(:, 1);

error = actual_RIR - estimated_RIR;
abs_error = norm(error, 2);

% Calculate the power of the signal and noise
signal_power = mean(actual_RIR.^2);
noise_power = mean(error.^2);

% Calculate SNR
snr_value = 10 * log10(signal_power / noise_power);

% Display the SNR
disp(['SNR = ', num2str(snr_value), ' dB']);
