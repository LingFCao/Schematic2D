function internalSetDoubleStraightTextBox( obj, startPosition, endPosition )
% Textbox position is translated to the mid-point ...

obj.internalSetStraightTextBox( startPosition, endPosition );
% translate the text-box to the mid-point 
midcoord = .5 * ( startPosition + endPosition );

obj.movetextbox( midcoord );