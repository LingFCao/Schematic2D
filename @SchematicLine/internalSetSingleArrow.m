function internalSetSingleArrow( obj, startPosition, endPosition )
% a simple arrow, going from ''startPosition'' to ''endPosition''.

xlim = obj.parent.parent.Axs.XLim;
ylim = obj.parent.parent.Axs.YLim;
defaultLineContainer = obj.rightLine;
xdata = startPosition(1);
ydata = startPosition(2);
udata = endPosition(1) - startPosition(1);
vdata = endPosition(2) - startPosition(2);
switch obj.arrowstyle
    case 'patch'
        % determine the length
        dr = sqrt( udata * udata + vdata * vdata ) + 1E-7;
        width  = obj.headproportion * dr;
        height = obj.headproportion * dr;
        xpos = xdata + (1 - obj.headproportion) * udata;
        ypos = ydata + (1 - obj.headproportion) * vdata;
        pstr = SchematicCircle.staticSetArrowHead( ...
            xpos, ...
            ypos, ...
            udata / dr, ...
            vdata / dr, ...
            width, ...
            height);
        if isempty( obj.rightLine )
            obj.rightLine = plot( ...
                obj.parent.parent.Axs, ...
                [xdata, xpos], ...
                [ydata, ypos], ...
                'visible', 'off', ...
                'pickableparts', 'none', ...
                obj.CurrentPropertyCell{:} );
        else
            set( obj.rightLine, ...
                'xdata', [xdata, xpos], ...
                'ydata', [ydata, ypos] );
        end
        if isempty( obj.arrowhead )
            obj.arrowhead = patch( ...
                obj.parent.parent.Axs, ...
                'xdata', pstr.x, ...
                'ydata', pstr.y, ...
                'edgealpha', 0, ...
                'visible', 'off', ...
                'pickableparts', 'none', ...
                'facecolor', obj.fillColor );
        else
            set( obj.arrowhead, ...
                'xdata', pstr.x, ...
                'ydata', pstr.y, ...
                'facecolor', obj.fillColor);
        end
    case 'quiver'
        % make sure that 'autoscale' is off by default ...
        if isempty( defaultLineContainer )
            % if the container is empty, we create a quiver object ...
            defaultLineContainer = quiver( ...
                obj.parent.parent.Axs, ...
                xdata, ...
                ydata, ...
                udata, ...
                vdata, ...
                'autoscale', 'off', ...
                'visible',   'off', ...
                'pickableparts', 'none', ...
                obj.CurrentPropertyCell{:} );
            % save reference to the rightLine property ... 
            obj.rightLine = defaultLineContainer;
        else
            % set the 'xdata', 'ydata', 'udata', 'vdata', etc.
            set( defaultLineContainer, 'xdata', xdata', 'ydata', ydata, 'udata', udata', 'vdata', vdata );
        end
end
obj.parent.parent.aaxis( [xlim, ylim] );