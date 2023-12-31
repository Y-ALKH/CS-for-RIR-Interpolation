


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

locations = [[1.330 1.050 0.535];
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
RIRs = RIRs.';
actual_RIR = actual_RIR.';
room_dimensions = [3.9, 2.85, 2.9];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%---------------------------------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Estimate the RIR at the target location
estimated_RIR = cs_interpolate(target_location, RIRs, locations, room_dimensions);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%---------------------------------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Estimated RIR at the new location

error = actual_RIR - estimated_RIR;
abs_error = norm(error, 2);

% Calculate the power of the signal and noise
signal_power = mean(actual_RIR.^2);
noise_power = mean(abs_error.^2);

% Calculate SNR
snr_value = 10 * log10(signal_power / noise_power);

% Display the SNR
disp(['SNR = ', num2str(snr_value), ' dB']);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%---------------------------------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function estimated_RIR = cs_interpolate(target_location, RIRs, locations, room_dimensions)
    % Inputs:
    % target_location - The [x, y, z] coordinates of the target location
    % RIRs - A matrix of size [132300, 20] containing the RIRs at 20 locations
    % locations - A matrix of size [20, 3] containing the [x, y, z] coordinates for each RIR
    % room_dimensions - The [length, width, height] of the room

    % Output:
    % estimated_RIR - The estimated RIR at the target location

    % Number of samples in each RIR
    num_samples = size(RIRs, 1);

    % Construct the sensing matrix (A) based on room dimensions and RIR locations
    A = construct_sensing_matrix(locations, room_dimensions, num_samples, target_location);

    % Solve the optimization problem to find the sparse coefficients
    % Regularization parameter (this might need tuning)
    lambda = 0.0001;
    Eavg = mean(sum(RIRs.^2, 1));
    % Solve the optimization problem with regularization
    cvx_begin
        variable x(20)
        minimize(norm(x, 1))
        subject to
            sum_square_abs(A*x) >= Eavg
    cvx_end

    % Reconstruct the estimated RIR at the target location
    estimated_RIR = A * x;
end

function A = construct_sensing_matrix(locations, room_dimensions, num_samples, target_location)
    % Number of RIR locations
    num_locations = size(locations, 1);

    % Speed of sound in air (approx. 343 meters per second)
    speed_of_sound = 343;

    % Maximum possible delay (time for sound to travel across the diagonal of the room)
    max_delay = norm(room_dimensions) / speed_of_sound;

    % Sampling rate (assuming it matches the length of RIRs and maximum delay)
    sampling_rate = num_samples / max_delay;

    % Initialize the sensing matrix
    A = zeros(num_samples, num_locations);

    % Construct the sensing matrix
    for i = 1:num_locations
        % Calculate the distance from each RIR location to the target location
        distance = norm(locations(i, :) - target_location);

        % Calculate the time delay for sound to travel this distance
        time_delay = distance / speed_of_sound;

        % Determine the sample index corresponding to this time delay
        delay_sample = round(time_delay * sampling_rate);

        % Attenuation factor (simplified model, can be more complex in reality)
        attenuation = 1 / (distance + 1);

        % Populate the column corresponding to this RIR location
        if delay_sample < num_samples
            A((delay_sample + 1):end, i) = attenuation;
        end
    end
end

