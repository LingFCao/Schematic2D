classdef (ConstructOnLoad) SchematicDestroyEventData < event.EventData
    properties
        destroyedObjReference;
    end
    methods
        function obj = SchematicDestroyEventData( objRef )
            obj.destroyedObjReference = objRef;
        end
    end
end