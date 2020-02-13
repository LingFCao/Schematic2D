function internalImportImageDestory( obj )
% destroys the imported image, which is residing in the canvas' parent
% object. We invokes its local destroy routine.
obj.parent.destroyImageObj();
obj.imager.reset();
%  reset imager 
obj.internalImageReset();