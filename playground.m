% Define the four lists of SNR values (replace with your data)
SNR_list1 = [-12.31, -10.40, -3.93, -5.88, -6.71, -1.23];
SNR_list2 = [-21.97, -21.94, -22.48, -22.99, -23.42, -25.26];
SNR_list3 = [-0.84, -6.90, 2.03, -9.13, -9.27, -8.54];
SNR_list4 = [-8.13, -4.19, -5.26, -4.98, -0.87, -3.52];

% Define the x-axis values from 0 to 160 with steps of 10
x_axis = 0:30:160;

% Create a matrix with 6 values between 0 and 150 to highlight specific points
highlight_values = [20, 30, 50, 70, 100, 150];

% Create a figure and set properties
figure;
hold on;
grid on;
grid minor;

% Plot the four SNR lists with different colors and markers
plot(highlight_values, SNR_list1, '-o', 'DisplayName', 'Convex Optimization', 'LineWidth', 1.5);
plot(highlight_values, SNR_list2, '-s', 'DisplayName', 'Sinc Interpolation', 'LineWidth', 1.5);
plot(highlight_values, SNR_list3, '-d', 'DisplayName', 'Neural Network', 'LineWidth', 1.5);
plot(highlight_values, SNR_list4, '-^', 'DisplayName', 'Weighting', 'LineWidth', 1.5);

% Set axis labels and title
xlabel("Number of RIRs");
ylabel('SNR Values');
title('SNR Values vs. Number of RIRs');
xticks(0:10:160);
yticks(-30:5:5);

% Add a legend
legend('Location', 'Best');

% Hold off to finish the plot
hold off;
