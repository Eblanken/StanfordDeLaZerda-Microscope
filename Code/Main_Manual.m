%
% File: Main_Manual.m
% -------------------
% Author: Erick Blankenberg
% Date 8/1/2018
% 
% Description:
%   This program acts as an interface for the new flouroscopy microscope.
%   This version requires the user to use the manual stage while acquiring
%   a composite image.
%

% ---------------------------------- Settings -----------------------------



% -------------------------------- The Program ----------------------------

% -> Sets up GUI and Camera

% -> Streams the latest images from the camera, allows the user to take an
%    image to save, append to the current panorama, etc.
exitProgram = false;
cameraManager = Manager_Camera(0);
figure(1);
while(~exitProgram) % Main loop just shows camera footage
    hold on;
    imshow(cameraManager.acquireImage(5));
    hold off;
end

% --------------------------------- Functions -----------------------------