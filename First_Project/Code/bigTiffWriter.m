%%class to write tiff files to a folder
classdef bigTiffWriter < ImageAdapter
properties(GetAccess = public, SetAccess = private)        
        Filename;        
        TiffObject;
        TileLength;
        TileWidth;        
    end
    
    methods
        %tile length+width should be multiples of 16
        function obj = bigTiffWriter(fname, imageLength, imageWidth, tileLength, tileWidth, compression)
       obj.Filename   = fname;
            obj.ImageSize  = [imageLength, imageWidth, 1];
            obj.TileLength = tileLength;
            obj.TileWidth  = tileWidth;
            
            % Create the Tiff object.
            obj.TiffObject = Tiff(obj.Filename, 'w8');
            
         
            obj.TiffObject.setTag('ImageLength',   obj.ImageSize(1));
            obj.TiffObject.setTag('ImageWidth',    obj.ImageSize(2));
            obj.TiffObject.setTag('TileLength',    obj.TileLength);
            obj.TiffObject.setTag('TileWidth',     obj.TileWidth);
            obj.TiffObject.setTag('Photometric',   Tiff.Photometric.RGB);
            obj.TiffObject.setTag('BitsPerSample', 8);
            obj.TiffObject.setTag('SampleFormat',  Tiff.SampleFormat.UInt);
            obj.TiffObject.setTag('SamplesPerPixel', 3);
            obj.TiffObject.setTag('PlanarConfiguration', Tiff.PlanarConfiguration.Chunky); 
            
            if(compression)
                obj.TiffObject.setTag('Compression', Tiff.Compression.JPEG);
            end
        end
        
        
        function [] = writeRegion(obj, region_start, region_data)
            % Write a block of data to the tiff file.
            
            % Map region_start to a tile number.
            tile_number = obj.TiffObject.computeTile(region_start);
            
            % If region_data is greater than tile size, this function
            % warns, else it will silently pads with 0s.
            obj.TiffObject.writeEncodedTile(tile_number, region_data);
           
        end
        
        
        function data = readRegion(~,~,~) %#ok<STOUT>
            % Not implemented.
            error('bigTiffWriter:noReadSupport',...
                'Read support is not implemented.');
        end
        
        
        function close(obj)
            % Close the tiff file
            obj.TiffObject.close();
        end
        
    end    
end