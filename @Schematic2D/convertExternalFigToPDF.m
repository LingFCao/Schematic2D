function convertExternalFigToPDF( obj, FIG, filename, printSpecifier, printspaceoffset)
% A simple conversion that converts the 'FIG' object to 'PDF' and outputs
% the file to the image output folder stored in the canvas ...
%

defaultprintspecifier   = 'axes';    % prints the area bounded by
defaultprintspaceoffset = [];        %
if nargin > 3
    defaultprintspecifier   = printSpecifier;
end
if nargin > 4
    defaultprintspaceoffset = printspaceoffset;
end
try
    printobj = parseAndCheckInputObjectAndPrintSpecifier( FIG, defaultprintspecifier );
catch me
    %
    switch me.identifier
        case 'SchematicTools:Canvas:illegalkeyword'
            msg = ['The optional specifier must be a char-vector with the following values: ', ...
                '''axes'' or ''figure''!'];
        case 'SchematicTools:Canvas:illegaltype'
            msg = [...
                'The type of the supplied print object must be a valid instance of the following classes: ', ...
                '''figure'', ', '''axes'', ', '''GUIOUTPUT'', ', '''SolutionMonitor''.']; 
        otherwise
            rethrow( me );
    end
    me = MException( ...
        'SchematicTools:Canvas:export', msg );
    rethrow( me );
end
%
filename = [obj.workImagePath, filename];
if strcmpi( defaultprintspecifier, 'axes' )
    convertAxesToPDF( printobj, filename, defaultprintspaceoffset );
else
    %
    convertFigToPDF(  printobj, filename );
end



function convertAxesToPDF( axeshandle, filename, printspaceoffset )
% assume that the unit of the axeshandle is normalized.

fig = axeshandle.Parent;

isvisible = strcmpi( get( fig, 'visible' ), 'on' );
if ~isvisible, set( fig, 'visible', 'on' ); end
defaultoffset = axeshandle.TightInset;
if ~isempty( printspaceoffset ), defaultoffset = printspaceoffset; end
defaultAxesPosition = axeshandle.Position;
% combine with the offset
modAxesPosition = defaultAxesPosition;
modAxesPosition(1) = max( modAxesPosition(1) - defaultoffset(1), 0 );
modAxesPosition(2) = max( modAxesPosition(2) - defaultoffset(2), 0 );
modAxesPosition(3) = min( modAxesPosition(3) + sum( defaultoffset(1:2:end) ), 1);
modAxesPosition(4) = min( modAxesPosition(4) + sum( defaultoffset(2:2:end) ), 1);

% ratio = height / width 
ratio = modAxesPosition( 4 ) / modAxesPosition( 3 );

% two things to do here: scale the figure's position and the paper size 
currentFigPosition = fig.Position;
modFigPosition     = currentFigPosition;
modFigPosition(4) = ratio * modFigPosition(3);
set( fig, 'position', modFigPosition );

defaultpapersize  = fig.PaperSize;
modpapersize      = defaultpapersize;
modpapersize(2) = ratio * modpapersize(1);
set( fig, 'papersize', modpapersize );
print( fig, filename, '-dpdf', '-bestfit' );
% revert back to the default values ... 
set( fig, 'position', currentFigPosition, 'papersize', modpapersize );
if ~isvisible, set( fig, 'visible', 'off' ); end

function convertFigToPDF( fighandle, filename )

isvisible = strcmpi( get( fighandle, 'visible' ), 'on' ); 
if ~isvisible, set( fighandle, 'visible', 'on' ); end

currentFigPosition = fighandle.Position;
ratio = currentFigPosition( 4 ) / currentFigPosition( 3 );
currentPaperSize    = fighandle.PaperSize;
modPaperSize        = currentPaperSize;
modPaperSize(2) = modPaperSize(1) * ratio;
set( fighandle, 'papersize', modPaperSize );
print(fighandle, filename, '-dpdf', '-bestfit' );
% revert back to the default values ...
set( fighandle, 'papersize', currentPaperSize );
if ~isvisible, set( fighandle, 'visible', 'on' ); end

function printobjhandle = parseAndCheckInputObjectAndPrintSpecifier( ...
    inputobj, printspecifier)
% we parse the inputobj to check that if it contains any printable object
% and depending on the printspecifier, we return the correct handle of the
% print object... 

switch printspecifier
    case 'axes'
        % instructs the function to print the axes, valid inputobj
        % includes: 'Figure' (in this case, 'Figure' must have non-empty
        % child axes), 'GUIOUTPUT' (this is a custom class) or
        % 'SolutionMonitor' (custom class)
        try
            printobjhandle = getaxeshandle( inputobj );
        catch me
            rethrow( me );
        end
    case 'figure'
        try 
            printobjhandle = getfighandle( inputobj );
        catch me
            rethrow( me );
        end
    otherwise
        me = MException( ...
            'SchematicTools:Canvas:illegalkeyword', ...
            'the supplied ''printspecifier'' is not recognized!');
        throw( me );
end

function axeshandle = getaxeshandle( inputobj )
axeshandle = [];
switch class( inputobj )
    case 'matlab.ui.Figure'
        axeshandle = getAxesHandleFromFig( inputobj );
    case 'matlab.graphics.axis.Axes'
        if inputobj.isvalid, axeshandle = inputobj; end
    case 'GUIOUTPUT'
        axeshandle = getAxesHandleFromGUIOUTPUT( inputobj );
    case 'SolutionMonitor'
        axeshandle = getAxesHandleFromSolutionMonitor( inputobj ); 
    otherwise
        % throw an exception to handle the case
        me = MException( ...
            'SchematicTools:Canvas:illegaltype', ...
            'supplied input type unknown!');
        throw( me );
end
if isempty( axeshandle )
    me = MException( ...
        'SchematicTools:Canvas:invalidobj', ...
        'reference to a deleted object!' );
    throw( me );
end

function fighandle = getfighandle( inputobj )
fighandle = [];
switch class( inputobj )
    case 'matlab.ui.Figure'
        if inputobj.isvalid, fighandle = inputobj; end
    case 'matlab.graphics.axis.Axes'
        if inputobj.isvalid, fighandle = inputobj.Parent; end
    case 'GUIOUTPUT'
        if inputobj.isvalid && inputobj.Fig.isvalid, fighandle = inputobj.Fig; end
    case 'SolutionMonitor'
        % refers to the mastgui
        if inputobj.isvalid && ...
                inputobj.MasterGUI.isvalid && inputobj.MasterGUI.Fig.isvalid
            fighandle = inputobj.MasterGUI.Fig;
        end
    otherwise
        me = MException( ...
            'SchematicTools:Canvas:illegaltype', ...
            'supplied input type unknown!');
        throw( me );
end
if isempty( fighandle )
    me = MException( ...
        'SchematicTools:Canvas:invalidobj', ...
        'reference to a deleted object!' );
    throw( me );
end

function axeshandle = getAxesHandleFromGUIOUTPUT( gui )
% simply checks and returns the axes handle from 'gui' 

axeshandle = []; 
if isempty( gui.Axs ), return; end
if ~gui.Axs.isvalid  , return; end

axeshandle = gui.Axs;

function axeshandle = getAxesHandleFromFig(   fig  )
% simply checks and returns the axes handle from 'fig', a figure object

axeshandle = [];
for p = fig.Children
    if isa(p, 'matlab.graphics.axis.Axes' ) && p.isvalid
        axeshandle = p; 
        return; 
    end
end
 
function axeshandle = getAxesHandleFromSolutionMonitor( sol )
% simply checks and returns the axes handle from 'SolutionMonitor' obj 

axeshandle = [];
if ~isempty( sol.ChildGUIContainer ), axeshandle = getAxesHandleFromGUIOUTPUT( sol.ChildGUIContainer(end) ); end




