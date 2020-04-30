
    %defines region based reading and writing of images for svs files
    %   impelemnts the abstract class ImageAdapter, with the methods
    %   readRegion, close, and optional writeregion
classdef PageTiffAdapter < ImageAdapter
    properties
        Filename
        Info
        Page
        %we don't include imagesize in properties because it's already a
        %property of the base class. we still initialize it at the bottom
    end
    methods 
        function obj = PageTiffAdapter(filename, page) %the constructor
            obj.Filename = filename;
            obj.Info = imfinfo(filename);
            obj.Page = page;
            obj.ImageSize = [round(obj.Info(page).Height) round(obj.Info(page).Width)];
        end
        function result = readRegion(obj, start, count)
            result = imread(obj.Filename,'Index',obj.Page,...
                'Info',obj.Info,'PixelRegion', ...
                {[start(1), start(1) + count(1) - 1], ...
                [start(2), start(2) + count(2) - 1]});
        end
        function result = close(obj) %#ok
        end
        %function writeRegion if we want to create new files
    end
end