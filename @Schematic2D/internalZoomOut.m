function internalZoomOut(  obj  )
% zoom out: applies the transformation x' + (1 + ds)* (x - x'), where ds is
% the zoom step, x' is the anchor coordinate, to the xlim and ylim

anchor = obj.currentZoomAnchor;
if isempty( anchor ), return; end

% obtain the xlim and ylim
xlim = obj.parent.Axs.XLim;
ylim = obj.parent.Axs.YLim;
% what is the zoom step?
ds   = obj.zoomStep;

xlim = anchor(1) + (1 + ds) * (xlim - anchor(1));
ylim = anchor(2) + (1 + ds) * (ylim - anchor(2));
obj.parent.aaxis( [xlim, ylim] );