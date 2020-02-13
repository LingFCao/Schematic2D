function internalSetSingleArrowTextBox( obj, startPosition, endPosition )
% check if text-box is created, and add necessary compts if not

obj.internalSetSingleArrow( startPosition, endPosition );

if isempty( obj.textBox )
    % text box is empty
    obj.addtextbox( startPosition );
else
    % we simply move the textbox to the startPosition
    obj.movetextbox( startPosition );
end