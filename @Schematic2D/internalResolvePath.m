function internalResolvePath( obj, pathinput )

if ~(  iscell( pathinput ) || ischar( pathinput ) )
    me = MException( 'SchematicTools:Canvas:invalidtype', ...
        'The specified path must be either a cell array containing the name of the paths or a char-vector!');
    throw( me );
end
% no attempt is made to check whether such path exists... 
defaultpathinput = pathinput;
if iscell( defaultpathinput )
    % check if the cell-size is 3 ... 
    if length( defaultpathinput ) == 1
        defaultpathinput = pathinput{1};
        defaultspecifier = 'single';
    elseif length( defaultpathinput ) == 3
        defaultpathinput = pathinput;
        defaultspecifier = 'multipole';
    else
        me = MException( ...
            'SchematicTools:Canvas:incorrectdimension', ...
            'Incorrect input cell size!');
        throw( me );
    end
    obj.setpath(defaultspecifier, defaultpathinput);
end
if ischar( defaultpathinput ), obj.setpath('single', defaultpathinput); end