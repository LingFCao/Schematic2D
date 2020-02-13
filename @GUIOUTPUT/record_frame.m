function record_frame(obj, target)
% store a snapshot of the current frame on target
DefaultTarget = obj.DefaultCapObj; UseFigContainer = strcmpi(obj.CapObj, 'figure'); 
CurrentFrameCount = obj.DefaultFrameCount;
if nargin > 1
    assert(ischar(target), ...
        'GUIOUTPUT:inputs:invalidType', ...
        'specified target must be a character string!');
    assert(strcmpi(target, 'axes') || strcmpi(target, 'figure'), ...
        'GUIOUTPUT:inputs:illegalKeyword', ...
        'specify target as ''axes'' or ''figure''');
    if strcmpi(target, 'axes')
        DefaultTarget = obj.Axs;
        UseFigContainer = false;
        CurrentFrameCount = obj.CurrentNumberOfAxeFrames;
    end
end
% frame is stored to the relevant container
if CurrentFrameCount > obj.MaxFrameToBeStored
    warning( ...
        'GUIOUTPUT:FrameRecord:maxFrameLimitReached', ...
        'frame count has reached the specified limit, record is disabled');
    return;
end
CurrentFrameCount = CurrentFrameCount + 1; frame = getframe(DefaultTarget);
if UseFigContainer
    obj.FigFrameContainer = [obj.FigFrameContainer, frame];
    obj.CurrentNumberOfFigFrames = CurrentFrameCount;
else
    obj.AxeFrameContainer = [obj.AxeFrameContainer, frame];
    obj.CurrentNumberOfAxeFrames = CurrentFrameCount;
end
if strcmpi(obj.CapObj, 'figure')
    obj.DefaultFrameCount = obj.CurrentNumberOfFigFrames;
else
    obj.DefaultFrameCount = obj.CurrentNumberOfAxeFrames;
end