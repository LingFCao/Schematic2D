function AdjustedDeleteFig(~, DataObjectBeingPassed, guiobject)
% to delete the figure, press 'q' to quite the figure
KeyBeingPressed = DataObjectBeingPassed.Character;
ToDelete = strcmpi(KeyBeingPressed, '0');
if ToDelete
    msg = 'attempt to delete fig in 2 secs';
    disp(msg);
    pause(2);
    guiobject.ClearGraphContent();
end
