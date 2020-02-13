function [stringcell, datafile] = outputstream( obj )
% returns a cell-array of the main components of the current obj. This is
% used by its parent to auto-generate the code on a separate .m file ...

datafile = [];
% output datapath ... 
stringhead = { [ obj.name, ' = SchematicLine( canvas, ', Schematic2D.staticgetstringasoutput(obj.style), ', ...' ] };
% attach property names 
prop = obj.CurrentPropertyCell;
num  = length( prop );
propcell = cell(1, num/2);
propstringprefix =  '    ';
propstringaftfix = ', ...';
for k = 1 : num / 2 - 1
    propcell{ k } = [ propstringprefix, ...
        Schematic2D.staticgetstringasoutput( prop{ 2 * k - 1 } ), ', ', ...
        Schematic2D.staticgetstringasoutput( prop{ 2 * k } ), propstringaftfix ];
end
k = num / 2;
propcell{ num / 2 } = [ propstringprefix, ...
        Schematic2D.staticgetstringasoutput( prop{ 2 * k - 1 } ), ', ', ...
        Schematic2D.staticgetstringasoutput( prop{ 2 * k } ), ');'];
% set name 
string00 = { [ obj.name, '.name = ', Schematic2D.staticgetstringasoutput( obj.name ), ';'] };
    
% we also need to attach to the current text box property ()
string01 = ' ';
string02 = ' ';
specialstring = {};
textIsEnabled = ...
    strcmpi( obj.style, 'straighttextbox' ) || ...
    strcmpi( obj.style, 'doublestraighttextbox' ) || ...
    strcmpi( obj.style, 'singlearrowtextbox' ) || ...
    strcmpi( obj.style, 'doublearrowtextbox' );
arrowIsEnabled = ...
    strcmpi( obj.style, 'singlearrow' ) || ...
    strcmpi( obj.style, 'singlearrowtextbox' ) || ...
    strcmpi( obj.style, 'doublearrow' ) || ...
    strcmpi( obj.style, 'doublearrowtextbox' );
if textIsEnabled
    substringhead = { [ obj.name, '.setProperties( ''textbox'', ...'] };
    prop = obj.currentTextboxPropertyCell;
%     prop = [
%         {'string, ', obj.textBox.String}, ...
%         prop ];
    num  = length( prop );
    textpropcell = cell(1, num / 2 );
    for k = 1 : num / 2 - 1 
        textpropcell{ k } = [ propstringprefix, ...
            Schematic2D.staticgetstringasoutput( prop{ 2 * k - 1 } ), ', ', ...
            Schematic2D.staticgetstringasoutput( prop{ 2 * k + 0 } ), propstringaftfix ];
    end
    k = num / 2;
    textpropcell{ num /2 } = [ propstringprefix, ...
            Schematic2D.staticgetstringasoutput( prop{ 2 * k - 1 } ), ', ', ...
            Schematic2D.staticgetstringasoutput( prop{ 2 * k + 0 } ), ');'];
    string01 = [ substringhead, textpropcell];
    string02 = { [ obj.name, '.setTextboxSize( ', ...
        Schematic2D.staticgetstringasoutput( obj.defaultTextBoxWidth ), ', ', ...
        Schematic2D.staticgetstringasoutput( obj.defaultTextBoxHeight), ');'] };
    % special string 
    specialstring = { [ obj.name, '.setText( ', Schematic2D.staticgetstringasoutput( obj.textBox.String ), ' );' ] };
end
%
substringhead = { [ obj.name, '.draw( ...' ] };
substring01   = { [propstringprefix, '''start'', ', Schematic2D.staticgetstringasoutput( obj.internalStartPosition ), propstringaftfix ] };
if arrowIsEnabled
    substring02   = { [propstringprefix, '''end'',   ', Schematic2D.staticgetstringasoutput( obj.internalFinalPosition ), propstringaftfix ] };
    substring02   = [ substring02, { [propstringprefix, '''arrowscale'',    ', Schematic2D.staticgetstringasoutput( obj.headproportion ), ');'] } ];
else
    substring02   = { [propstringprefix, '''end'',   ', Schematic2D.staticgetstringasoutput( obj.internalFinalPosition ), ');'] };
end
string03      = [substringhead, substring01, substring02];
stringcell    = [ stringhead, propcell, string00, string01, string02, string03, specialstring];
