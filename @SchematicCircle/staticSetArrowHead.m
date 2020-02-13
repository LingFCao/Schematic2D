function patchStruct = staticSetArrowHead( xpos, ypos, xdir, ydir, width, height)
% static method: computes the coordinates of the arrow heads and returns as
% a patch struct, which contains the following field 'x', 'y'

% we assume that the dimensions of the inputs are the same, else we let
% matlab throw any exceptions

% also, all inputs are assumed row-vector.

xnormal = -ydir;
ynormal = +xdir;

xwest   = xpos + .5 * width.*xnormal;
ywest   = ypos + .5 * width.*ynormal;

xeast   = xpos - .5 * width.*xnormal;
yeast   = ypos - .5 * width.*ynormal;

xnorth  = xpos + height.*xdir;
ynorth  = ypos + height.*ydir;

patchStruct = struct( ...
    'x', [xwest; xnorth; xeast], ...
    'y', [ywest; ynorth; yeast] );