%
% File: Manager_Camera.m
% -------------------
% Author: Erick Blankenberg
% Date 8/1/2018
% 
% Description:
%   This class acts as an interface for one Thorcam camera.
%

classdef Manager_Camera
    % This class manages camera settings and the camera connection.
    
    properties(Access = 'private')
        camera = [];
        cameraMemoryId = [];
        cameraWidth = [];
        cameraHeight = [];
        cameraBits = [];
    end
    
    methods(Access = 'public')
        %
        % Description:
        %   Camera object constructor.
        %
        % Parameters:
        %   'cameraID' The ID of the camera.
        %
        function obj = Manager_Camera(cameraID)
            % Attempts to open a camera
            NET.addAssembly('C:\Program Files\Thorlabs\Scientific Imaging\DCx Camera Support\Develop\DotNet\uc480DotNet.dll');
            obj.camera = uc480.Camera;
            obj.camera.Init(cameraID);
            obj.camera.Display.Mode.Set(uc480.Defines.DisplayMode.DiB); % Bitmap mode
            obj.camera.PixelFormat.Set(uc480.Defines.ColorMode.RGBA8Packed); % 8 bit color
            obj.camera.Trigger.Set(uc480.Defines.TriggerMode.Software); % Software trigger
            [~, memoryID] = obj.camera.Memory.Allocate(true);
            obj.cameraMemoryId = memoryID;
            [~, Width, Height, Bits, ~] = cam.Memory.Inquire(obj.cameraMemoryId);
            obj.cameraWidth = Width;
            obj.cameraHeight = Height;
            obj.cameraBits = Bits;
        end
        
        %
        % Description:
        %   Camera object deconstructor.
        %
        function delete(obj)
            obj.camera.Exit;
        end
        
        % 
        % Description:
        %   Captures several images and returns the average.
        %
        % Parameters:
        %   'numFrameAverages' The number of images to combine into one.
        %
        % Returns:
        %   'newImage' The composite image.
        %
        function newImage = acquireImage(obj, numFrameAverages)
            acquisitions = zeros(obj.cameraWidth, obj.cameraHeight, numFrameAverages);
            for index = 1:numFrameAverages
                cam.Acquisition.Freeze(uc480.Defines.DeviceParameter.Wait);
                [~, tmp] = cam.Memory.CopyToArray(obj.cameraMemoryId);
                Data = reshape(uint8(tmp), [obj.cameraBits/8, obj.cameraWidth, obj.cameraHeight]);
                Data = Data(1:3, 1:obj.cameraWidth, 1:obj.cameraHeight);
                Data = permute(Data, [3, 2, 1]);
                acquisitions(:, :, index) = rgb2gray(Data);
            end
            newImage = mean(acquisitions, 3);
        end
        
        %
        % Decription:
        %   Captures a new image and immediately saves it to the disk.
        %
        % Parameters:
        %   'numFrameAverages' The number of frames to average when capturing.
        %   'varargin'         Optional argument for the name of the file
        %                      to save. Otherwise uses current date and
        %                      time.
        %
        function saveImage(obj, numFrameAverages, varargin)
            time = clock;
            folderName = sprintf('Acquisitions\Snapshots');
            imageName = [];
            if(isempty(varargin) > 0)
                imageName = varargin(1);
            else
                imageName = sprintf('Image_Manual_%d\%d\%d_%d:$d:%d', time(2), time(3), time(1) , time(4), time(5), time(6));
            end
            imageName = sprintf('%s.png', imageName);
            fullPath = sprintf('%s/%s', folderName, imageName);
            imwrite(obj.acquireImage(numFrameAverages), fullPath);
        end
    end
    
    methods(Access = 'private')
    end
    
end
