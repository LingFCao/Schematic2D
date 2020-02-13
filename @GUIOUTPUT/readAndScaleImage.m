function readAndScaleImage( obj, filename, varargin )
% reads an image from file, followed by scale the current image to fit the
% axes' range 

% check that if there is an already existed image object. If it has,
% destroy it on the spot
if ~isempty( obj.imageObj ), obj.imageObj.delete(); obj.imageObj = []; end


A = imread( filename, varargin{:} );
xlim = obj.Axs.XLim;
ylim = obj.Axs.YLim; 

obj.imageObj = image( ...
    obj.Axs, ...
    xlim, ...
    ylim(end:-1:1), ...
    A, ...
    'pickableparts', 'none', ...
    'alphadata', 1.0);
if strcmpi( obj.Axs.XDir, 'reverse' ), set( obj.Axs, 'xdir', 'normal' ); end
if strcmpi( obj.Axs.YDir, 'reverse' ), set( obj.Axs, 'ydir', 'normal' ); end
if strcmpi( obj.Axs.ZDir, 'reverse' ), set( obj.Axs, 'zdir', 'normal' ); end

% reset back to the range if it is not being so already 
obj.aaxis( [xlim, ylim] );