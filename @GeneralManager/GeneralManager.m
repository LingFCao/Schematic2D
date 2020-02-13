classdef GeneralManager < handle
    % general-object container class.
    properties(SetAccess = private)
        NumberOfObj      =    0;
        ObjContainer;
        CatDimension;
    end
    methods
        % let matlab handle the default constructor
        function obj = GeneralManager(catdim)
            if nargin
                obj.CatDimension = catdim;
            else
                obj.CatDimension =      2;
            end
        end
        function add(obj, newobj)
            % add current object to the current container. Ignores any
            % duplicate.
            IsObjInCurrentContainer = false;
            if ~isempty( obj.ObjContainer )
                IsObjInCurrentContainer = any(obj.ObjContainer == newobj);
            end
            if ~IsObjInCurrentContainer
                % let matlab handle issues related to type compatibility
                obj.NumberOfObj = obj.NumberOfObj + 1;
                obj.ObjContainer = cat(obj.CatDimension, obj.ObjContainer, newobj);
            end
        end
        function reset(obj)
            if ~isempty(obj.ObjContainer)
                %obj.ObjContainer.delete; % do not delete the objects in
                %the container
                obj.ObjContainer = [];
                obj.NumberOfObj = 0;
            end
        end
        function DeleteAllObj(obj)
            for p = obj.ObjContainer
                p.delete();
            end
            obj.reset();
        end
        function DeleteObjReference(obj, id)
            % Delete the object references (make sure that 'id' is unique
            % )! 
            id = id( id > 0 & id <= obj.NumberOfObj );
            if ~isempty( id )
                n = numel( id );
                obj.NumberOfObj = max( obj.NumberOfObj - n, 0 );
                obj.ObjContainer( id ) = [];
            end
        end
        function obj_ref = GetObjRef(obj, id)
            % outputs the obj reference in the container/no check on 'id'
            id = id( id > 0 & id <= obj.NumberOfObj );
%             noref = id < 0 || id > obj.NumberOfObj;
            noref = isempty( id );
            if noref, obj_ref = [];return;end
            obj_ref = obj.ObjContainer(id);
        end
        function emptyflag = isContainerEmpty(obj)
            emptyflag = obj.NumberOfObj <= 0;
        end
        function contsize = getSize(obj)
            contsize = obj.NumberOfObj;
        end
        function id = getObjID(obj, obj_in_container)
            % returns the object id
            id = 0;
            id_ = find(obj.ObjContainer == obj_in_container,1,'first');
            if ~isempty(id_)
                id = id_;
            end
        end
        function con = getAll(obj)
            % returns the whole container
            con = obj.ObjContainer;
        end
        function LastRef = getLastRef(obj)
            if obj.NumberOfObj < 1, LastRef = []; return; end
            LastRef = obj.ObjContainer(end);
        end
        function FirstRef = getFirstRef(obj)
            if obj.NumberOfObj < 1, FirstRef = []; return; end
            FirstRef = obj.ObjContainer(1);
        end
        function NextRef = getNextRef(obj, CurrentRef)
            if isnumeric(CurrentRef)
                I = CurrentRef;
            else
                I = find(obj.ObjContainer == CurrentRef,1,'first');
                if isempty(I)
                    error('Container does not contain input ref');
                end
            end
            if I >= obj.NumberOfObj || I <= 0
                NextRef = []; return;
            end
            NextRef = obj.ObjContainer(I + 1);
        end
        function sort(obj, I)
            % sort the container according to 'I'. Let Matlab handle
            % exception
            if ~obj.isContainerEmpty
                obj.ObjContainer = obj.ObjContainer(I);
            end
        end
    end
end