% List of sound file paths
filePaths = {'11.m4a', '12.m4a', '13.m4a', '14.m4a', '15.m4a', '16.m4a', '21.m4a', '22.m4a', '23.m4a', '24.m4a', '25.m4a', '26.m4a', '31.m4a', '32.m4a', '33.m4a', '34.m4a', '35.m4a', '36.m4a', '41.m4a', '42.m4a', '43.m4a', '44.m4a', '45.m4a', '46.m4a'}; 

% Number of files
numFiles = length(filePaths);

% Estimate or determine the length of the sound files (in samples)
% This is an example value; adjust it based on your actual sound files
numSamples = 2000; % Example for 10 seconds at 44.1 kHz

% Preallocate the matrix to store the sound data
% Each row will be a sound file
soundData = zeros(numFiles, numSamples);

% Read each sound file and store it in the matrix
for i = 1:numFiles
    % Read the sound file
    [audio, fs] = audioread(filePaths{i});
    
    % Check if the audio is stereo and convert to mono if necessary
    if size(audio, 2) > 1
        audio = mean(audio, 2); % Convert to mono by averaging channels
    end
    
    % Truncate or zero-pad the audio to fit the preallocated matrix
    audioLength = length(audio);
    if audioLength > numSamples
        audio = audio(1:numSamples); % Truncate
    elseif audioLength < numSamples
        audio = [audio; zeros(numSamples - audioLength, 1)]; % Zero-pad
    end
    
    % Store the audio in the matrix
    soundData(i, :) = audio';
end

% soundData now contains each sound file as a row
disp('Sound data matrix:');
save ("data_matrix_real.mat", "soundData");
