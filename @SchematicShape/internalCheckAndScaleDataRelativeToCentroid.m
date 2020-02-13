function internalCheckAndScaleDataRelativeToCentroid(obj, xraw, yraw)
% first we check that 'xraw' and 'yraw' are row-vectors

if ~isvector( xraw ), xraw = xraw(:).'; end
if ~isrow( xraw ),    xraw = xraw.';    end

if ~isvector( yraw ), yraw = yraw(:).'; end
if ~isrow( yraw ),    yraw = yraw.';    end


[xmin, xMinIndex] = min( xraw ); [xmax, xMaxIndex] = max( xraw );
[ymin, yMinIndex] = min( yraw ); [ymax, yMaxIndex] = max( yraw ); 
% get the xlim and ylim
x0   = obj.parent.parent.Axs.XLim(1);
x1   = obj.parent.parent.Axs.XLim(2);

y0   = obj.parent.parent.Axs.YLim(1);
y1   = obj.parent.parent.Axs.YLim(2);
dataIsInRange = ...
    ( x0 <= xmin && xmax <= x1 ) && ...
    ( y0 <= ymin && ymax <= y1 );
if ~dataIsInRange
    % if data is not in range then we determine the largest scale factor
    % such that the scaled data fit within the xlim and ylim of the canvas
    
    % first determine the centroid of the unprocessed data set
    numberOfElements = numel( xraw ); 
    xcentroid = sum( xraw ) / numberOfElements;
    ycentroid = sum( yraw ) / numberOfElements;
    
    xcentroidOfCanvas = .5 * (x0 + x1);
    ycentroidOfCanvas = .5 * (y0 + y1);
    
    xtranslation = xcentroidOfCanvas - xcentroid;
    ytranslation = ycentroidOfCanvas - ycentroid;
    xraw = xraw + xtranslation;
    yraw = yraw + ytranslation;
    % translate the anchor position
    obj.position.setCircleGeometry( obj.position.position + [xtranslation, ytranslation] );
    % check if the translated data are still within bounds
    dataIsInRange = ...
        ( x0 <= xraw( xMinIndex ) && xraw( xMaxIndex ) <= x1 ) && ...
        ( y0 <= yraw( yMinIndex ) && yraw( yMaxIndex ) <= y1 );
    if ~dataIsInRange
        % data is still not in range. Determine the largest scale factor
        % we have 4 canditors
        c1x = abs( xraw( xMinIndex ) - xcentroidOfCanvas );
        c2x = abs( xraw( xMaxIndex ) - xcentroidOfCanvas );
        c1y = abs( yraw( yMinIndex ) - ycentroidOfCanvas );
        c2y = abs( yraw( yMaxIndex ) - ycentroidOfCanvas );
        % add a small non-zero constant to avoid division by zero
        eps = 1E-7;
        c1x = c1x + eps;
        c2x = c2x + eps;
        c1y = c1y + eps;
        c2y = c2y + eps;
        scaleFactory = min( ...
            [...
            .5 * (y1 - y0) / c1y, ...
            .5 * (y1 - y0) / c2y, ...
            .5 * (x1 - x0) / c1x, ...
            .5 * (x1 - x0) / c2x ] );
        % now scale relative to the centroid
        obj.xRawData = xraw;
        obj.yRawData = yraw;
        obj.internalScaleData( [xcentroidOfCanvas, ycentroidOfCanvas], scaleFactory );
    else
        % now data is in range ... 
        obj.xRawData = xraw;
        obj.yRawData = yraw;
        notify(obj, 'RawDataModified');
    end
else
    obj.xRawData = xraw;
    obj.yRawData = yraw;
    notify(obj, 'RawDataModified' );
end