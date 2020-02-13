function [stringcell, datafile] = outputstream( obj )
% returns a cell-array of the main components of the current obj. This is
% used by its parent to auto-generate the code on a separate .m file ...

datafile = [];
if ~isempty( obj.xRawData ) && ~isempty( obj.yRawData )
    % if the data are obtained via a filename previously, we check if such
    % file still exists. If it does, override it without generating a new
    % file name
    if ~isempty( obj.datafilename ) && exist( obj.datafilename, 'file') == 2
        % current file exists 
        filename = obj.datafilename;
    else
         % generate name ... 
        % the name has the format: '.../name_2020_03_02_14_08.dat'
        filename = [ ...
            obj.parent.workMdataPath, ...
            obj.name, Schematic2D.staticgetclockasstring(), '.dat'];
        
    end
    % check if given data size is less than a given threshold, in this case
    % it is 10
    dataSizeLessThanThreshold = length( obj.xRawData ) < 11; 
    if ~dataSizeLessThanThreshold
        % now write to output ... 
        dlmwrite( filename, [obj.xRawData.', obj.yRawData.'] );
        datafile = filename;
    end
else
    stringcell = {''}; return;
end
% output datapath ... 
stringhead = { [ obj.name, ' = SchematicShape( canvas, ', Schematic2D.staticgetstringasoutput(obj.style), ', ...' ] };
% attach property names 
prop = obj.currentPropertyCell;
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
propcell{ num /2 } = [ propstringprefix, ...
        Schematic2D.staticgetstringasoutput( prop{ 2 * k - 1 } ), ', ', ...
        Schematic2D.staticgetstringasoutput( prop{ 2 * k } ), ');'];
% stringtail = [propstringprefix, ');'];
% set name identifier ... 
string00 = { [ obj.name, '.name = ', Schematic2D.staticgetstringasoutput( obj.name ), ';'] };

% set fillShape ...
string01   = { [ obj.name, '.fillShape = ', Schematic2D.staticgetstringasoutput( obj.fillShape ), ';'] };
% set filColor ... 
string02   = { [ obj.name, '.setFillColor(', Schematic2D.staticgetstringasoutput( obj.fillColor ), ');'] };
% set sample size ... 
string03   = { [ obj.name, '.setSamplingSize(', Schematic2D.staticgetstringasoutput( obj.SampleSize ), ');'] };
% set data based on the output
if ~dataSizeLessThanThreshold
    % it previously saved a copy of the raw data ... now we have to load it
    % from system 
    
    % set data from file
    string04 = { [ obj.name, '.getDataFromDataFile(',  Schematic2D.staticgetstringasoutput( datafile ), ');'] };
else
    % here we simply use the addpoint to construct
    numOfData = length( obj.xRawData );
    dataToAddCell = cell(1, numOfData );
    for k = 1 : numOfData
        dataToAddCell{ k } = [ obj.name, '.addpoint( ', Schematic2D.staticgetstringasoutput( [ obj.xRawData( k ), obj.yRawData( k ) ] ), ' );'];
    end
    substring04 = { [obj.name, '.make();' ] };
    string04    = [ dataToAddCell, substring04];
end

string05 = { [ obj.name, '.draw();' ] };
% set 'inautogenmode' (to prevent duplication of data)
string06 = { [ obj.name, '.inautogenmode = ', Schematic2D.staticgetstringasoutput( true ), ';'] };

% set face alpha
string07 = { [ obj.name, '.setAlphaData( ', Schematic2D.staticgetstringasoutput( obj.faceAlpha ), ');'] };

stringcell = [stringhead, propcell, string00, string01, string02, string03, string04, string05, string06, string07];

