function pixelbin = iterateimagewithoutsmoothing( obj, startposition, initialdirection, endposition )
% iterate the image using the gradient descend. The position update is
% obtained by applying a Gausssian weighted average to the pixel locations
% with a core size of 0.1. The direction is computed by fitting a linear
% regression to the last 5 computed locations.

useEndPositionAsTerminationCriteria = false;
if nargin > 3 && ~isempty( endposition )
    % use this termination criterion if the optional 'endposition' is
    % supplied.
    useEndPositionAsTerminationCriteria = true;
    xe = endposition(1); 
    ye = endposition(2);
end
% the core parameter is used to define the Gaussian weight, in general the
% smaller the value the more narrow is the search for a specific matching
% color. But one should be careful not to set it too small or else Matlab
% may return 0
core          = .1;

% create the reference to the helper
helper = obj.pointhelper;

% reset the helper
helper.reset();

% these are the dimensions of the image to be traced 
rown = obj.rowNumb;
coln = obj.colNumb;

% set-up a short-cut handle to quickly convert the [x,y] coord to the row
% and col indices
cv   = @(x, y) convert(x, y, rown, coln);

% set the starting position which is given as the normalized coordinates
x1   = startposition(1);
y1   = startposition(2);

% add the first point to the helper (note it is not yet enough to compute
% the tangent line)

helper.addpoint( [x1, y1] );

% what is [x1, y1] in terms of [row, col]? 
[row, col] = cv( x1, y1 );

% load the rgb image, whose elements consist of [r,g,b] triplets
im = obj.rgbImage;

% 'step' is used in the initial search. For an 'eastward' direction, the
% intial search creates a box of certain dimension equivalent to 'st'
% number of pixels oriented in the 'east' direction excluding the initial
% pixel position.
st = obj.Step;

% now since we have the row and col, it is time to extract the 'rgb' value
% from the image
if ~isempty( obj.guideRGB )
    % if this field is non-empty, we use the guideRGB as a matching critera
    % 
    rs = obj.guideRGB( 1 ) + 1E-6;
    gs = obj.guideRGB( 2 ) + 1E-6;
    bs = obj.guideRGB( 3 ) + 1E-6;
else
    % else use the local color determined by the starting position.
    rs = im( row, col, 1)  + 1E-6; % the scalar 1E-6 is used to ensure that we are not dividing zero.
    gs = im( row, col, 2)  + 1E-6;
    bs = im( row, col, 3)  + 1E-6; 
end

% obtain the indices for the initial search given by the 'initialdirection'
% input ...
[I, J] = SchematicImageProcessor.getDirectionalIndices( ...
    row, col, rown, coln, st,  initialdirection);

% exit early if the indices are empty(this simply means the starting
% position is too close to the image border)
if isempty( I ) || isempty( J ), pixelbin = [] ; return; end
%%  
% compute the 'rgb' values for the I, J tuplets. Vectorize the element
% access by turning I,J to linear indices (noting that Matlab matrices use
% col-majored storage pattern)

idx = ( J - 1 ) * rown + I;
r   = im( idx                  );
g   = im( idx + 1 * rown * coln);
b   = im( idx + 2 * rown * coln);

% The next position is determined by weighting all of the surrounding
% pixels against the matching color. The Gaussian weight has the advantage
% that pixels with dissimilar color drop to zero exponentially fast (the
% rate is thus controlled by the core parameter!). 
f   =  exp( -.5 * ( (r - rs).^2 + (g - gs).^2 + (b - bs).^2 ) / (core * core) );
F   =  sum( f );
% we favor 'furthest' points with matching color (note how similar it is to
% finding the center of gravity?)
row_ = sum( f.*I ) / F;
col_ = sum( f.*J ) / F;

% convert to the normalized coordinates and append to the helper
x2   = ( col_ - 1 )    / (coln - 1);
y2   = ( rown - row_)  / (rown - 1);
% append points to the helper
helper.addpoint( [x2, y2] );

% the helper should have enough point to compute the tangent
[tx, ty] = helper.compute();

% store to the iterative variables
row    = row_;
col    = col_;
% define the iteration paramters ... 
currentIter    = 0;
maxIter        = obj.maxIteration;

% set output variables
pixelbin       = zeros(obj.maxIteration + 1, 2);
pixelbin(1, :) = [row, col];

% not done, at least go through an iteration
done = false;

% define the characteristic pixel length in the normalized coordinate
% system.
pixelLength   = max( 1 / rown, 1 / coln );

% bsize is the length of the bounding box rotated 45[deg] relative to the
% direction vector
bsize         = obj.boundingSize * pixelLength;
pixelind      = @(tx, ty, i, j) SchematicImageProcessor.getpixelind( tx, ty, i, j, rown, coln, bsize);
while ~done
    % obtain the (I, J) pairs
    [I, J] = pixelind( tx, ty, row, col );
    % exit early if they are empty ...
    if isempty( I ) || isempty( J ), break; end
    % linear indexing follows by extracting the rgb values
    idx = ( J - 1 ) * rown + I;
    r   =  im( idx                   );
    g   =  im( idx + 1 * rown * coln );
    b   =  im( idx + 2 * rown * coln );
    % apply the weight wk = fk / F, where
    f   =  exp( -.5 * ( (r - rs).^2 + (g - gs).^2 + (b - bs).^2 ) / (core * core) );
    F   =  sum( f );
    row_ = sum( f.*I ) / F;
    col_ = sum( f.*J ) / F;
    % determine the new direction
    x2   = ( col_ - 1 )    / (coln - 1);
    y2   = ( rown - row_)  / (rown - 1);
    % continue to accumulate points to the helper ...
    helper.addpoint( [x2, y2] );
    [tx, ty] = helper.compute();
    row  = floor( row_ );
    col  = floor( col_ );
    % increment the iteration counter now
    currentIter = currentIter + 1;
    pixelbin(currentIter + 1, :) = [row, col];
    % output row and col to the container (we could apply some critera to
    % determine the suitability of adding current point. An example will be
    % the distance between the last added node, so if the distance is too
    % small one may simply ignore the addition. This way, the points will
    % be nicely spaced. But that is a task for the future ...)
    if useEndPositionAsTerminationCriteria
        % check if current position x2 and y2 is within the termination
        % length
        r = norm( [x2, y2] - [xe, ye] );
        isWithin = false;
        if r < obj.withinpixels * pixelLength
            isWithin = true;
        end
        done = currentIter >= maxIter || isWithin;
    else
        done = currentIter >= maxIter;
    end
end
obj.pixelBin = pixelbin( 1 : currentIter + 1, :);

function [row, col] = convert( x, y, imax, jmax )
% a basic conversion routine
col = 1 + floor( ( jmax - 1 ) * x  );
row = imax - floor( (imax - 1) * y );





