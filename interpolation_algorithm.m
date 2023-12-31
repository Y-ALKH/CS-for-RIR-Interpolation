
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




%{
% Example usage
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
new_location = [2.900 1.290 0.001]; % Replace with the new location
actual_RIR = data_real.soundData(21,:);

[predicted_RIR, absolute_error, SNR] = estimate_RIR(locations, RIRs, new_location);

function [predicted_RIR, absolute_error, SNR] = estimate_RIR(locations, RIRs, new_location, actual_RIR)
    % Inputs:
    % locations - Nx3 matrix of RIR locations
    % RIRs - Nx2000 matrix of RIRs (2000 samples each)
    % new_location - 1x3 vector of the new location
    % actual_RIR (optional) - Actual RIR at the new location for error calculation

    % Regression model using Neural Network
    net = fitnet(10); % 10 hidden neurons, adjust as needed
    net.divideParam.trainRatio = 0.85;
    net.divideParam.valRatio = 0.15;
    net.divideParam.testRatio = 0;

    % Train the network
    net = train(net, locations', RIRs');

    % Predict the RIR at the new location
    predicted_RIR = net(new_location')';

    % Append Gaussian random noise to complete the RIR
    noise = normrnd(0, 1, [1, 130300]); % Adjust the mean and std as needed
    predicted_RIR = [predicted_RIR, noise];

    % Initialize error and SNR
    absolute_error = NaN;
    SNR = NaN;

    % Calculate absolute error and SNR if actual RIR is provided
    if exist('actual_RIR', 'var')
        absolute_error = mean(abs(actual_RIR - predicted_RIR));
        signal_power = mean(actual_RIR .^ 2);
        noise_power = mean((actual_RIR - predicted_RIR) .^ 2);
        SNR = 10 * log10(signal_power / noise_power);
    end
end

%}



%{


% Algorithm 1:
% Objective function for Gurobi (minimize the 1-norm of s)
f = [ones(n, 1); ones(n, 1)]; % Coefficients for [s; -s]

% Inequality constraints (A*s <= b)
b = [y; -y];
% Ensure A is a sparse matrix
A_sparse = sparse([Phi, -Phi; -Phi, Phi]);

% Set up the Gurobi model
model.modelname = 'cs_optimization';
model.A = A_sparse;
model.obj = f;
model.rhs = b;
model.sense = repmat('<', size(A_sparse, 1), 1); % '<' for each constraint
model.modelsense = 'min';

% Variable types: continuous
model.vtype = 'C';

% Gurobi parameters (if needed)
params.outputflag = 0; % Set to 1 to see Gurobi output

% Solve the problem using Gurobi
result = gurobi(model, params);

% Extract the solution
s_gurobi = result.x(1:n) - result.x(n+1:end);

% Display the solution
disp('The sparse coefficient vector s is:');
disp(s_gurobi);

%{


% Ensure CVX is installed and set up
cvx_setup;

% Convex optimization to solve for s
cvx_begin
    variable s(n)
    minimize(norm(s, 1))
    subject to
        Phi * s == y
cvx_end

% Output the solution
disp('The sparse coefficient vector s is:');
disp(s);
%}

%-------------------------------------------------------------------------%
% Algorithm 2:
m = rows(impulse_responses);
n = cols(impulse_responses);

s = optimvar('s');
y = optimvar('y');
phi = impulse_responses;
psi = dftmtx(m);
theta = phi * psi;
equality = theta * s == y;

prob = optimproblem;
prob.Objective = norm(s,1);
prob.Constraints.cons1 = equality;

solution2 = solve(prob);

%-------------------------------------------------------------------------%
% Algorithm 3:
m = rows(impulse_responses);
n = cols(impulse_responses);

s = optimvar('s');
y = optimvar('y');
phi = impulse_responses;
psi = dftmtx(m);
theta = phi * psi;
sigma = 0.01;

prob = optimproblem;
prob.Objective = norm(s,1);
prob.Constraints.cons1 = 1/2*norm(y-theta*s, 2) <= sigma;

solution3 = solve(prob);

%}

