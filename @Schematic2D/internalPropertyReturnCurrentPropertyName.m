function [propertynamecell, logicalVec, propertyvalcell] = internalPropertyReturnCurrentPropertyName( obj )
% returns the current property name
logicalVec = false(1, 11);
propertynamecell = {'', '', '', '', '', '', '', '', '', '', ''};
propertyvalcell  = {'', '', '', '', '', '', '', '', '', '', ''};
counter = obj.schematicContainer.getSize(); namereset = ['schematicObj', num2str( counter + 1 ) ];
obj.propertyArrowTextStruct.name = namereset;
obj.propertyCircleStruct.name    = namereset;
obj.propertyShapeStruct.name     = namereset;
obj.propertyTextStruct.name      = namereset;
switch obj.currentModeState
    case 1
        propertynamecell = { ...
            'style:', ...
            'fill?:' , ...
            'fillC:', ...
            'alpha:', ...
            'color:', ...
            'linwid:', ...
            'linsty:', ...
            'name:', ...
            '', ...
            '', ... 
            ''};
        propertyvalcell = { ...
            evaluatearg( obj.propertyShapeStruct.style), ...
            evaluatearg( obj.propertyShapeStruct.fillShape ), ...
            evaluatearg( obj.propertyShapeStruct.fillColor ), ...
            evaluatearg( obj.propertyShapeStruct.facealpha ), ...
            evaluatearg( obj.propertyShapeStruct.color     ), ...
            evaluatearg( obj.propertyShapeStruct.linewidth ), ...
            evaluatearg( obj.propertyShapeStruct.linestyle ), ...
            evaluatearg( obj.propertyShapeStruct.name ) , ...
            '', ...
            '', ...
            ''};
        logicalVec(1:8) = true;
    case 2
        % none at this point
        propertynamecell = { ...
            '', ...   %1
            '', ...   %2
            '', ...   %3
            '', ...   %4
            '', ...   %5
            '', ...   %6
            '', ...   %7
            '', ...   %8
            '', ...   %9
            '', ...   %10
            ''};
        propertyvalcell = { ...
            '', ...
            '', ...
            '', ...
            '', ...
            '', ...
            '', ...
            '', ...
            '', ...
            '', ...
            '', ...
            ''};
    case 3
        propertynamecell = { ...
            'style:', ...
            'color:', ...
            'width:', ...
            'height:', ...
            'tcolor:', ...
            'bcolor:', ...
            'ecolor:', ...
            'fontsiz:', ...
            'name:',  ...
            '', ...
            ''};
        propertyvalcell = { ...
            evaluatearg( obj.propertyTextStruct.style ), ...
            evaluatearg( obj.propertyTextStruct.color ), ...
            evaluatearg( obj.propertyTextStruct.width ), ...
            evaluatearg( obj.propertyTextStruct.height), ...
            evaluatearg( obj.propertyTextStruct.textcolor ), ...
            evaluatearg( obj.propertyTextStruct.backgroundcolor ), ...
            evaluatearg( obj.propertyTextStruct.edgecolor ), ...
            evaluatearg( obj.propertyTextStruct.fontsize ), ...
            evaluatearg( obj.propertyTextStruct.name ), ...
            '', ...
            ''};
        logicalVec(1:9) = true;
    case 4
        propertynamecell = { ...
            'style:', ...
            'color:', ...
            'linwid:', ...
            'linsty:', ...
            'width:', ...
            'height:', ...
            'tcolor:', ...
            'bcolor:', ...
            'ecolor:', ...
            'fontsiz:', ...
            'name:'};
        propertyvalcell = { ...
            evaluatearg(obj.propertyArrowTextStruct.style), ...
            evaluatearg(obj.propertyArrowTextStruct.color), ...
            evaluatearg(obj.propertyArrowTextStruct.linewidth), ...
            evaluatearg(obj.propertyArrowTextStruct.linestyle), ...
            evaluatearg(obj.propertyArrowTextStruct.width), ...
            evaluatearg(obj.propertyArrowTextStruct.height), ...
            evaluatearg(obj.propertyArrowTextStruct.textcolor), ...
            evaluatearg(obj.propertyArrowTextStruct.backgroundcolor), ...
            evaluatearg(obj.propertyArrowTextStruct.edgecolor), ...
            evaluatearg(obj.propertyArrowTextStruct.fontsize), ...
            evaluatearg(obj.propertyArrowTextStruct.name)};
        logicalVec(:) = true;
    case 5
        propertynamecell = { ...
            'style:', ...
            'color:', ...
            'fill?:', ...
            'linwid:', ...
            'linsty:', ...
            'radius:', ...
            'ipolar:', ...
            'fpolar:', ...
            'name:', ...
            '', ...
            ''};
        logicalVec(1:9) = true;
        propertyvalcell = { ...
            evaluatearg( obj.propertyCircleStruct.style ), ...
            evaluatearg( obj.propertyCircleStruct.color ), ...
            evaluatearg( obj.propertyCircleStruct.fillShape ), ...
            evaluatearg( obj.propertyCircleStruct.linewidth ), ...
            evaluatearg( obj.propertyCircleStruct.linestyle ), ...
            evaluatearg( obj.propertyCircleStruct.radius ), ...
            evaluatearg( obj.propertyCircleStruct.ipolar ), ...
            evaluatearg( obj.propertyCircleStruct.fpolar ), ...
            evaluatearg( obj.propertyCircleStruct.name ), ...
            '', ...
            ''};
end

function str = evaluatearg( arg )
str = arg;
if isnumeric( arg ), str = num2str( arg ); return; end
if islogical( arg ), str = num2str( arg ); return; end