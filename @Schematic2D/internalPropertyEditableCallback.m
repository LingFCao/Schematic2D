function internalPropertyEditableCallback( obj, ~, ~, fieldID, uiobj)
% note that uiobj corresponds to each of the field IDs. The idea is that we
% change the field value based on the string of the uiobj
string = uiobj.String;
switch obj.currentModeState
    case 1
        switch fieldID
            case 1
                obj.propertyShapeStruct.style = checkshapestyle( string );
            case 2
                obj.propertyShapeStruct.fillShape = logical( str2double( string ) );
            case 3
                obj.propertyShapeStruct.fillColor = convertToColorSpec( string );
            case 4
                obj.propertyShapeStruct.facealpha = str2double( string );
            case 5
                obj.propertyShapeStruct.color     = convertToColorSpec( string );
            case 6
                obj.propertyShapeStruct.linewidth = str2double( string );
            case 7
                obj.propertyShapeStruct.linestyle = checklinemarkerstyle( string );
            case 8
                obj.propertyShapeStruct.name = string;
                obj.useCustomName = true;
        end
    case 3
        switch fieldID
            case 1
                obj.propertyTextStruct.style = checklinestyle( string );
            case 2
                obj.propertyTextStruct.color = convertToColorSpec( string );
            case 3
                obj.propertyTextStruct.width = str2double( string );
            case 4
                obj.propertyTextStruct.height = str2double( string );
            case 5
                obj.propertyTextStruct.textcolor = convertToColorSpec( string );
            case 6
                obj.propertyTextStruct.backgroundcolor = convertToColorSpec( string );
            case 7
                obj.propertyTextStruct.edgecolor = convertToColorSpec( string );
            case 8
                obj.propertyTextStruct.fontsize = str2double( string );
            case 9
                obj.propertyTextStruct.name = string;
                obj.useCustomName = true;
        end
    case 4
        switch fieldID
            case 1
                obj.propertyArrowTextStruct.style = checklinestyle( string );
            case 2
                obj.propertyArrowTextStruct.color = convertToColorSpec( string );
            case 3
                obj.propertyArrowTextStruct.linewidth = str2double( string );
            case 4
                obj.propertyArrowTextStruct.linestyle = checklinemarkerstyle( string );
            case 5
                obj.propertyArrowTextStruct.width = str2double( string );
            case 6
                obj.propertyArrowTextStruct.height = str2double( string );
            case 7
                obj.propertyArrowTextStruct.textcolor = convertToColorSpec( string );
            case 8
                obj.propertyArrowTextStruct.backgroundcolor = convertToColorSpec( string );
            case 9
                obj.propertyArrowTextStruct.edgecolor = convertToColorSpec( string );
            case 10
                obj.propertyArrowTextStruct.fontsize = str2double( string );
            case 11
                obj.propertyArrowTextStruct.name = string;
                obj.useCustomName = true;
        end
        
    case 5
        switch fieldID
            case 1
                obj.propertyCircleStruct.style = checkcirclestyle( string );
            case 2
                obj.propertyCircleStruct.color = convertToColorSpec( string );
            case 3
                obj.propertyCircleStruct.fillShape = logical( str2double( string ) );
            case 4
                obj.propertyCircleStruct.linewidth = str2double( string );
            case 5
                obj.propertyCircleStruct.linestyle = checklinemarkerstyle( string );
            case 6
                obj.propertyCircleStruct.radius = str2double( string );
            case 7
                obj.propertyCircleStruct.ipolar = str2num( string );
            case 8
                obj.propertyCircleStruct.fpolar = str2num( string );
            case 9
                obj.propertyCircleStruct.name = string;
                obj.useCustomName = true;
        end
end
function linestyle = checklinestyle( styleinput )
predefinedlist = { 'straight', 'straighttextbox', 'singlearrow', 'singlearrowtextbox', 'doublestraighttextbox', 'doublearrow', 'doublearrowtextbox' };
linestyle = [];
for k = 1 : 7
    if strcmpi( styleinput, predefinedlist{ k } )
        linestyle = predefinedlist{ k }; return;
    end
end
if isempty( linestyle )
    warning( ...
        'SchematicTools:Canvas:illegalkeyword', ...
        'illegal line style, style is set to ''straight''!');
    linestyle = 'straight';
end

function shapestyle = checkshapestyle( styleinput )
predefinedlist = { 'open', 'close' };
shapestyle = [];
for k = 1 : 2
    if strcmpi( styleinput, predefinedlist{ k } )
        shapestyle = predefinedlist{ k }; return;
    end
end
if isempty( shapestyle )
    warning( ...
        'SchematicTools:Canvas:illegalkeyword', ...
        'illegal shape style, style is set to ''open''!');
    shapestyle = 'open';
end
function circlestyle = checkcirclestyle( styleinput )
predefinedlist = { 'circle', 'arc', 'counterclockeddy', 'clockeddy' };
circlestyle = [];
for k = 1 : 4
    if strcmpi( styleinput, predefinedlist{ k } )
        circlestyle = predefinedlist{ k }; return;
    end
end
if isempty( circlestyle )
    warning( 'SchematicTools:Canvas:illegalkeyword', ...
        'illegal circle style, style is set to ''circle''!' );
    circlestyle = 'circle';
end
function markerstyle = checklinemarkerstyle( strinput )
predefinedlist = {'-', '-.', ':'};
markerstyle = [];
for k = 1:3
    if strcmpi( strinput, predefinedlist{ k } )
        markerstyle = predefinedlist{ k };
    end
end
if isempty( markerstyle )
    warning( ...
        'SchematicTools:Canvas:illegalkeyword', ...
        'illegal line style, style is set to ''-''!');
    markerstyle = '-';
end

function colorspec = convertToColorSpec( strinput )
listOfCharColorSpec = { 'y', 'm', 'c', 'r', 'g', 'b', 'w', 'k', 'none'};
% check for the string input and compare to the predefined short name ... 
for k = 1 : 9
    colorisoneofthepredefinedspecs = strcmpi( strinput, listOfCharColorSpec{ k } );
    if colorisoneofthepredefinedspecs
        colorspec = listOfCharColorSpec{ k }; return;
    end
end
colorspec = str2num( strinput );
if isempty( colorspec )
    % invalid spec and throw a warning 
    warning( ...
        'SchematicTools:Canvas:illegalkeyword', ...
        'illegal color data, color is set to ''k''!');
    colorspec = 'k';
    
end

