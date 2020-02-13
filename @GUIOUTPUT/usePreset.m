function usePreset( obj )
% set preset properties on the gui window. Those properties include:
%   (x,y,z) labels to current axis
%   minor grid-line to the current axis
%   equalize the current axis

% check if current axis is valid
assert(  isvalid( obj.Axs ),  ...
    'GUIOUTPUT:Axs:DestroyedObject', ...
    'cannot set preset properties on deleted axes object');

obj.xxlabel('$x$', 'interpreter', 'latex');
obj.yylabel('$y$', 'interpreter', 'latex');
obj.zzlabel('$z$', 'interpreter', 'latex');

% add grid-line
obj.ggrid('minor');

% equalize axis scale
obj.aaxis('equal');
