function internalInitialize( obj )
% initialize ... 

obj.xlowerbound = 0;
obj.xupperbound = 1;
obj.ylowerbound = 0;
obj.yupperbound = 1;

% ui-component containers
obj.statictextcompts   = GeneralManager();
obj.editabletextcompts = GeneralManager();
%
obj.editablelisteners  = GeneralManager();