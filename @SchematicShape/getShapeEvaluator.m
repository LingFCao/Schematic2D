function evaluator = getShapeEvaluator( obj )
% obtain the evaluator of the parameterized shape in an 'open' shape. 
if strcmpi( obj.style, 'open' ) && ~isempty( obj.ppstr )
    evaluator = @(s) bridge( obj.ppstr, s );
else
    evaluator = @dummybridge;
end



function [x, y] = dummybridge( s )
x = zeros( size( s ) );
y = zeros( size( s ) );

function [x, y] = bridge(ppstr, s)
v = ppval( ppstr, s );
x = v(1, :);
y = v(2, :);