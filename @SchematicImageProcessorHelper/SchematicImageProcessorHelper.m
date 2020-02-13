classdef SchematicImageProcessorHelper < handle
    % a helper class 
    properties(SetAccess = private)
        currentCount   = 0;
        maxElements    = 5; % maximum elements to store 
        pointContainer = [];
    end
    properties(Access = private)
        parent;
    end
    methods
        function obj = SchematicImageProcessorHelper( Parent )
            obj.parent = Parent;
            obj.pointContainer = zeros( obj.maxElements, 2);
        end
        function addpoint( obj, point )
            if obj.currentCount < obj.maxElements
                % point = [x, y];
                obj.pointContainer( obj.currentCount + 1, :) = point;
                obj.currentCount = obj.currentCount + 1;
            else
                % move up the last n - 1 elements
                obj.pointContainer(1 : obj.currentCount - 1, :) = ...
                    obj.pointContainer( 2 : obj.currentCount, :);
                obj.pointContainer(end, :) = point;
            end
        end
        function [tx, ty] = compute( obj )
            tx = 1.0; ty = 0.0;
            if obj.currentCount < 2, return; end
            if obj.currentCount < 3
                tx = diff( obj.pointContainer(1:2, 1) );
                ty = diff( obj.pointContainer(1:2, 2) );
                rr = sqrt( tx * tx + ty * ty );
                tx = tx / rr;
                ty = ty / rr;
                return;
                
            else
                % more than 3 points - apply a linear regression 
                xi = obj.pointContainer(1 : obj.currentCount, 1);
                yi = obj.pointContainer(1 : obj.currentCount, 2);
                xixi = xi' * xi / obj.currentCount;
                xiyi = xi' * yi / obj.currentCount;
                xbar = mean( xi );
                ybar = mean( yi );
                a    = (xiyi - xbar * ybar ) / ( (xixi - xbar *xbar) + 1E-6 );
                normalization = sqrt(1 + a*a);
                tx   = 1 / normalization;
                ty   = a / normalization;
                
                sgn  = sign( ...
                    diff( xi( [1, obj.currentCount] ) ) * tx + ...
                    diff( yi( [1, obj.currentCount] ) ) * ty );
                tx   = sgn * tx;
                ty   = sgn * ty;
            end
        end
        function reset( obj )
            obj.currentCount = 0;
        end
    end
end