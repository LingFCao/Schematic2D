function isSchematicContainedAnyText = schematicContainsText( obj )

isSchematicContainedAnyText = ...
    strcmpi( obj.style, 'straighttextbox' ) || ...
    strcmpi( obj.style, 'doublestraighttextbox' ) || ...
    strcmpi( obj.style, 'singlearrowtextbox' ) || ...
    strcmpi( obj.style, 'doublearrowtextbox' );