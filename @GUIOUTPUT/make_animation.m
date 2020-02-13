function make_animation(obj, filename, varargin)
% make sure the movieobj property matches with the container in which the
% frames are stored. No check on the 'filename' is performed. So make sure
% the filename is appropriate
narginchk(2,inf);

% load the frame container
switch obj.CapObj
    case 'axes'
        FrameContainer = obj.AxeFrameContainer;
    case 'figure'
        FrameContainer = obj.FigFrameContainer;
end

if isempty(FrameContainer)
    warning( ...
        'GUIOUTPUT:MakeAnimation:emptyContainer', ...
        'specified container is empty');
    return;
end
c = 0; DefaultMovieOption = {'DelayTime', .0};
if nargin > 2
    DefaultMovieOption = varargin;
end
for frame = FrameContainer
    c = c + 1;
    im = frame2im(frame); [imind, cm] = rgb2ind(im, 256);
    if c == 1
        imwrite(imind, cm, filename, 'gif', 'Loopcount', inf, DefaultMovieOption{:});
    else
        imwrite(imind, cm, filename, 'gif', 'WriteMode', 'append', DefaultMovieOption{:});
    end
end
