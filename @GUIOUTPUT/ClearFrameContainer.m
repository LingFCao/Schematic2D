function ClearFrameContainer(obj, target)
DefaultTarget = obj.CapObj;
if nargin > 1, DefaultTarget = target;end
assert(ischar(DefaultTarget), ...
    'GUIOUTPUT:inputs:invalidType', ...
    'specified target is not a character string!');
validInput = ...
    strcmpi(DefaultTarget, 'axes') || ...
    strcmpi(DefaultTarget, 'figure') || ...
    strcmpi(DefaultTarget, 'all');
assert(validInput, ...
    'GUIOUTPUT:inputs:illegalKeyword', ...
    'specify target as ''axes'', ''figure'' or ''all''');
DefaultTarget = lower(DefaultTarget);
switch DefaultTarget
    case 'axes'
        obj.CurrentNumberOfAxeFrames = 0;
        obj.AxeFrameContainer = [];
    case 'figure'
        obj.CurrentNumberOfFigFrames = 0;
        obj.FigFrameContainer = [];
    case 'all'
        obj.CurrentNumberOfAxeFrames = 0;
        obj.CurrentNumberOfFigFrames = 0;
        obj.AxeFrameContainer = [];
        obj.FigFrameContainer = [];
end