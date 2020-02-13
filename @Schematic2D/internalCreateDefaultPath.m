function internalCreateDefaultPath( obj )
% create a default master folder ('schematic2dmaster') and three-associate
% folders ('mscriptfile', 'mscriptdata' and 'imageoutput') in the user's
% userpath

if obj.testOverrideAnyInputPaths
    obj.setpath( 'multiple' );
    return;
end

%%
% get userpath 
masterfolder    = [userpath,   '\schematic2dmaster'];
assomscriptfile = [masterfolder, '\mscriptfile'];
assomscriptdata = [masterfolder, '\mscriptdata'];
assoimageoutput = [masterfolder, '\imageoutput'];

% check if the master folder exists. If not, create it 

if exist( masterfolder, 'dir' ) ~= 7
    % make it now and three other associate
    mkdir(   masterfolder  );
    mkdir( assomscriptfile );
    mkdir( assomscriptdata ); 
    mkdir( assoimageoutput );
    % now set the output folder to 
    obj.workMscriptPath = [assomscriptfile, '\'];
    obj.workMdataPath   = [assomscriptdata, '\'];
    obj.workImagePath   = [assoimageoutput, '\'];
    
    % now add the masterfolder to the current matlab path
    addpath(genpath( masterfolder ) );
else
    % already created. just need to make it visible 
    addpath(genpath( masterfolder ) );
end


