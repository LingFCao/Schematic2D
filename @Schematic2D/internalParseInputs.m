function internalParseInputs( obj, varargin )
% this function parses the input cellarray and checks the legality of the
% property-names.
% 
% hmm the inputparser is not showing the behavior I want. Let's implement
% our own version ...
defaultnoparent = true; 
defaultnopaths  = true;



if nargin > 1
    % we want to make sure that the input format conforms to
    % 'propname'-'propvalue' pairs
    n = nargin - 1;
    assert( mod(n, 2) == 0, ...
        'SchematicTools:Canvas:invalidinputnumber', ...
        'Please ensure that the inputs conform to the ''propname'', ''propvalue'' format!' );
    for k = 1 : n/2
        assert( ischar( varargin{ 2*k - 1 } ), ...
            'SchematicTools:Canvas:invalidtype', ...
            'Please ensure that ''propertyname'' is a valid char-vector!' );
        nameInput  = lower( varargin{ 2 * k - 1} );
        valueInput = varargin{ 2 * k };
        switch nameInput
            case 'parent'
                % do not throw error
                if ~isa( valueInput, 'GUIOUTPUT' )
                    warning( ...
                        'SchematicTools:Canvas:invalidtype', ...
                        'The specified parent object is not a valid instance of the ''GUIOUTPUT''!');
                else
                    % use that as a figure container for the canvas
                    obj.parent = valueInput;
                    defaultnoparent = false;
                    % okay just to be sure that hold-state is turned on
                    obj.parent.hold( 'on' );
                end 
            case 'path'
               try
                   obj.internalResolvePath( valueInput );
               catch me
                   if strcmpi( me.identifier, 'SchematicTools:Canvas:invalidtype')
                       % throw a warning instead
                       warning( ...
                           'SchematicTools:Canvas:invalidtype', ...
                           'Path input must be specified as a 3-element cellarray or a char-vector');
                       continue;
                   elseif strcmpi( me.identifier, 'SchematicTools:Canvas:incorrectdimension' )
                       warning( ...
                           'SchematicTools:Canvas:incorrectdimension', ...
                           'Cellarray input must be specified as a 3-element array!');
                       continue;
                   else
                       rethrow( me );
                   end
               end
            case 'inprecision'
                % sets the inprecision factor (see property field for a
                % description)
                
                % validate attribute
                validateattributes(valueInput, {'double'}, ...
                    {'scalar', 'nonnan', 'nonzero', 'nonnegative'});
                obj.inprecision = valueInput;
            case 'traversalsteps'
                % sets the traversal step (applicable in translation,
                % rotation and scaling operations)
                validateattributes(valueInput, {'double'}, ...
                    {'scalar', 'nonnan', 'nonzero', 'nonnegative', '>', 1});
                obj.MinimumNumberOfTraversals = floor( valueInput );
            case 'zoomstepsize'
                % sets the custom zoom step
                validateattributes(valueInput, {'double'}, ...
                    {'scalar', 'nonnan', '>', 0, '<', .5} );
                obj.zoomStep = valueInput;
            otherwise
                % throw a warning instead and ignore its entry
                warning( ...
                    'SchematicTools:Canvas:illegalkeyword', ...
                    '%s is not a valid property name!', nameInput);
                
        end
    end
end


if defaultnoparent
    % if the parent object has not passed to the input, we initialize a
    % default figure container. i.e. a 'GUIOUTPUT' object
    obj.parent = GUIOUTPUT();
    % now configurate figure container 
    obj.internalConfigurateCanvas();
end

if defaultnopaths && ~obj.testOverrideAnyInputPaths
    % if no path input is recognised, create a default master folder on the
    % user directory
    obj.internalCreateDefaultPath();
end