function internalOutputContainerToScript( obj, filename )
% write content to '.m' file with filename given by 'filename', which needs
% to be a char-vector.

if obj.schematicContainer.isContainerEmpty(), return; end
% load the datapath ... 
openingstring   = ['function canvas = ', filename, '()' ];
filename = [ obj.workMscriptPath, '\', filename, '.m' ];

fileID = fopen( filename, 'w' ); 
spacestring = ' ';
% openingstring   = '%% This is an automatically generated script ...';
initialcomment  = '% This is an automically generated function script ... ';
creationstring  = '% create canvas';
if fileID < 0
    warning( ...
        'SchematicTools:Canvas:emptyfile', ...
        'failed to open %s!', filename );
    return;
else
    % flush the content ...
    canvastring = 'canvas = Schematic2D(); ';
    fprintf(fileID, '%s\n%s\n\n%s\n%s\n\n',openingstring, initialcomment, creationstring, canvastring);
    
    % close the fileID ... 
    fclose( fileID );
end

% check if we have any schematic objects ... 

% reload, this time, we switch to append mode 
fileID = fopen( filename, 'a' );
count  = 0;
for p = obj.schematicContainer.getAll()
    count = count + 1;
    delimitedstring = [ '% create schematic: ', num2str( count ) ];
    fprintf( fileID, '%s\n', delimitedstring );
    % get the str buffer ... 
    str = p.outputstream();
    for k = 1 : length( str )
        % print to the file ... 
        fprintf(fileID, '%s\n', str{ k } );
    end
    fprintf( fileID, '%s\n\n', spacestring);
end
% close the file ... 
fclose( fileID );

