function keyIsValid = CheckSchematicComponentKey( key )
% Checks the key against a list of restricted keys. The returned boolean
% output is true if 'key' is an element of the set of restricted keys 

keyIsValid = ...
    strcmpi( key, 'circle' ) || ...
    strcmpi( key, 'shape'  ) || ...                 % 
    strcmpi( key, 'line'   );                       % 
