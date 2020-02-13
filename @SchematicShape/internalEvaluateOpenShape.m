function internalEvaluateOpenShape( obj )
% one evaluates the closed shape
xlim = obj.parent.parent.Axs.XLim;
ylim = obj.parent.parent.Axs.YLim;
n = obj.SampleSize; S0 = obj.arcLength;
S = (0:n - 1) * S0 / (n - 1);

V = ppval( obj.ppstr, S );
xdata = V(1, :);
ydata = V(2, :);

% check if 'shape' is available
defaultShape = obj.shape;
if isempty( defaultShape )
    defaultShape = plot( ...
        obj.parent.parent.Axs, ...
        xdata, ...
        ydata, ...
        'visible', 'off', ...
        'pickableparts', 'none', ...
        obj.currentPropertyCell{:} );
    obj.shape = defaultShape;
else
    set( defaultShape, 'xdata', xdata, 'ydata', ydata);
end

% revert back to the xlim and ylim if it is not being done so automatically
obj.parent.parent.aaxis( [ xlim, ylim ] );