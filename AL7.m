

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%---------------------------------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Assuming RIRs and locations are already defined
estimated_RIR = kriging_interpolate(target_location, RIRs, locations);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%---------------------------------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Estimated RIR at the new location

error = actual_RIR - estimated_RIR;
abs_error = norm(error, 2);

% Calculate the power of the signal and noise
signal_power = mean(actual_RIR.^2);
noise_power = mean(error.^2);

% Calculate SNR
snr_value = 10 * log10(signal_power / noise_power);

% Display the SNR
disp(['SNR = ', num2str(snr_value), ' dB']);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%---------------------------------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function estimated_RIR = kriging_interpolate(target_location, RIRs, locations)
    % RIRs: Matrix of size [num_samples, num_RIRs] containing RIRs at multiple locations
    % locations: Matrix of size [num_RIRs, 3] containing the [x, y, z] coordinates for each RIR
    % target_location: [1, 3] vector specifying the [x, y, z] coordinates of the target location

    % Number of samples in each RIR and number of RIRs
    [num_samples, num_RIRs] = size(RIRs);

    % Preallocate the matrix for estimated RIR
    estimated_RIR = zeros(num_samples, 1);

    for i = 1:num_samples
        % Extract the i-th sample from all RIRs and transpose to column vector
        sample_points = RIRs(i, :).';

        % Perform Kriging interpolation for the i-th sample
        estimated_RIR(i) = perform_kriging(sample_points, locations, target_location);
    end
end

function estimated_value = perform_kriging(sample_points, locations, target_location)
    % Ensure sample_points is a column vector
    sample_points = sample_points(:);

    % Call fitrgp with correct dimensions
    gprMdl = fitrgp(locations, sample_points, 'BasisFunction', 'constant');
    
    % Predict for the target_location
    estimated_value = predict(gprMdl, target_location);
end
