


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
avg_snrs = zeros(m, m);
avg_snrs2 = [];
n = 0:20:1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%---------------------------------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:size(RIRs, 2)
    avg_snr = 0;
    for j = 1:size(RIRs, 2)
        if j ~= i
            avg_snr = avg_snr + find_snr(RIRs(:, i), RIRs(:, j));
            snr = find_snr(RIRs(:, i), RIRs(:, j));
            avg_snrs(i, j) = snr;
        end
    end
    avg_snr = avg_snr/m;
    avg_snrs2 = [avg_snrs2 avg_snr];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%---------------------------------------------%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function snr = find_snr(RIR1, RIR2)
    snr = 10*log10((mean(RIR1.^2))/(mean((RIR1 - RIR2).^2)));
end

