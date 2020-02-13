function internalSaveCapturedSelectionToPDF( obj, ~, ~ )
% callback that saves the selected region on the canvas to 'pdf'. This is
% normally triggered when user brings up the 'save as' panel and enters a
% filename to be exported to.

% ignore if the captured selection is empty AND the schematic container is
% empty
% if,  however, no selection was made, then we assume that the selection
% vector is the area bounded by the axes' xlim and ylim values

% obtain the string ... 
string = obj.editableobj.String;
% avoid accidental presses on other objects
if strcmpi( string, ''), return; end

if isempty( obj.internalCapturedSelection )
    xlim = obj.parent.Axs.XLim;
    ylim = obj.parent.Axs.YLim;
    obj.internalCapturedSelection = [xlim(1), ylim(1), xlim(2), ylim(2)];
end
% exit early if the aforementioned case occured
if isempty( obj.internalCapturedSelection ) || obj.schematicContainer.isContainerEmpty()
    return;
end
fprintf('%s ... \n', 'saving figure to .pdf format, please wait' );

xlim = obj.parent.Axs.XLim;
ylim = obj.parent.Axs.YLim;
% get the current axes position 
currentAxsPos = obj.parent.Axs.Position;
currentFigPos = obj.parent.Fig.Position;
% modify the axes
obj.parent.aaxis( [ obj.internalCapturedSelection(1:2:end), obj.internalCapturedSelection(2:2:end)] );
% determine the height/width ratio 
ratio  = diff( obj.internalCapturedSelection(2:2:end) ) / diff( obj.internalCapturedSelection(1:2:end) );
% obtain the pixel ratio
% pratio = obj.VerticalResolution / obj.HorizontalResolution;
pratio = 1;
set( obj.parent.Axs, 'position', [0, 0, 1, 1] );

modPos        = currentFigPos;
modPos(4)     = ratio * modPos(3) / pratio;
set( obj.parent.Fig, 'position', modPos );
% we set the paper size
defaultPaper = obj.parent.Fig.PaperSize;
modpapersize = defaultPaper;
modpapersize(2) = modpapersize(1) * ratio;
set( obj.parent.Fig, 'papersize', modpapersize);
associate = obj.schematicContainer.getFirstRef(); 
while ~isempty( associate )
    % we only update objects that contain text (it is weird how matlab
    % processes text objects when scaling, or any operations that result in
    % the scale being modified)
    if associate.schematicContainsText
        associate.draw();
    end
    associate = associate.getDoublyLinkedAssociate( 'forward' );
end
% resolve the stack order(necessary in cases that some of the objects may
% have been redrawn)
obj.internalCorrectStackOrder();

% disable the ui-components
set( obj.parent.Axs,        'visible', 'off' ); 
set( obj.ModeIdentifierUi,  'visible', 'off' );
set( obj.CoordinateDisplay, 'visible', 'off' );
set( obj.figExportModeDisp, 'visible', 'off' );
set( obj.importUIDisp     , 'visible', 'off' );
set( obj.xlockUIDisp      , 'visible', 'off' );
set( obj.ylockUIDisp      , 'visible', 'off' );
set( obj.mapui            , 'visible', 'off' );
% extensionType = '.pdf';
extensionType = [];
filename = [ obj.workImagePath, string, extensionType ];
% use the saveas to output the file to 'pdf' 
% saveas( obj.parent.Fig, filename );
print(obj.parent.Fig, filename, '-dpdf','-bestfit' );
set( obj.savepanel, 'visible', 'off' );
set( obj.editableobj, 'string', '' );
set( obj.parent.Fig,  'papersize', defaultPaper, 'papertype', 'a4' );

% reset the figure and axes position properties
obj.parent.aaxis([xlim, ylim] );
set( obj.parent.Axs, 'position', currentAxsPos);
set( obj.parent.Fig, 'position', currentFigPos);
% redraw again to make sure that we have the correct location of the text.
% Note only applies to schematic objects that contain text
associate = obj.schematicContainer.getFirstRef(); 
while ~isempty( associate )
    if associate.schematicContainsText
        associate.draw();
    end
    associate = associate.getDoublyLinkedAssociate( 'forward' );
end
% just to be saved from maintaining the correct stack order on the canvas.
obj.internalCorrectStackOrder();

% turn back on the ui-elements
set( obj.parent.Axs,        'visible', 'on' ); 
set( obj.ModeIdentifierUi,  'visible', 'on' );
set( obj.CoordinateDisplay, 'visible', 'on' );
set( obj.figExportModeDisp, 'visible', 'on' );
set( obj.importUIDisp     , 'visible', 'on' );
set( obj.mapui            , 'visible', 'on' );

% manually call the callbacks for the 'locks'!
obj.internalxlockCallback();
obj.internalylockCallback();

% reset the selection vector 
obj.internalCapturedSelection = [];