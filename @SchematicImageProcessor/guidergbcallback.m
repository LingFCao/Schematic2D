function guidergbcallback( obj, ~, ~, q )
string = q.String;
% just reset the guideRGB property in cases that a 'null' char is passed
if strcmpi(string, ''), obj.guideRGB = []; return; end
rgb    = checkColorSpec( string );
if ~isempty( rgb )
    if isscalar( rgb ), obj.guideRGB = []; return; end
    obj.guideRGB = rgb;
else
    rgb = str2num( string );
    if ~isempty( rgb )
        obj.guideRGB = rgb;
    end
end


function rgbvec = checkColorSpec( colorstring )
% check the colorstring
rgbvec = [];
colorkeys = { 'y', 'm', 'c', 'r', 'g', 'b', 'w', 'k', 'none' };
keyvalues = { ...
    [1 1 0], ...
    [1 0 1], ...
    [0 1 1], ...
    [1 0 0], ...
    [0 1 0], ...
    [0 0 1], ...
    [1 1 1], ...
    [0 0 0], ...
    1};
for k = 1 : 9
    if strcmpi( colorstring, colorkeys{ k } ), rgbvec = keyvalues{ k }; return; end
end