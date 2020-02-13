function internalSetTranslationStep( obj, ~, ~ )
% determine the translation length given a number of traversals

% get the xlim and ylim of current axes 
xlim = obj.parent.Axs.XLim;
ylim = obj.parent.Axs.YLim;
obj.selectionTranslationStep = min( [ diff( xlim ), diff( ylim ) ] / obj.MinimumNumberOfTraversals );