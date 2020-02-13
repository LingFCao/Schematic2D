function axisTypeCallback(obj, ~, ~, q )
string = q.String;

switch lower( string )
    case 'linear'
        % reset the default bounds
        obj.xlowerbound = 0; obj.xupperbound = 1;
        obj.ylowerbound = 0; obj.yupperbound = 1;
        % set the conversion handle to linear
        obj.conversionHandle = @obj.linearConvert;
        obj.axisType = 'linear';
    case 'semilogx'
        % reset default bounds
        obj.xlowerbound = 1; obj.xupperbound = 10;
        obj.ylowerbound = 0; obj.yupperbound =  1;
        obj.conversionHandle = @(xr, yr) obj.logotherConvert(xr, yr, 'semilogx');
        obj.axisType = 'semilogx';
    case 'semilogy'
        obj.xlowerbound = 0; obj.xupperbound =  1;
        obj.ylowerbound = 1; obj.yupperbound = 10;
        obj.conversionHandle = @(xr, yr) obj.logotherConvert(xr, yr, 'semilogy');
        obj.axisType = 'semilogy';
    case 'loglog'
        obj.xlowerbound = 1; obj.xupperbound = 10;
        obj.ylowerbound = 1; obj.yupperbound = 10;
        obj.conversionHandle = @(xr, yr) obj.logotherConvert(xr, yr, 'loglog');
        obj.axisType = 'loglog';
    otherwise
        % throw a warning and set default to 'linear'
        warning( ...
            'SchematicTools:ImageProcessor:illegalkeyword', ...
            ['type not recognised (''linear'', ''semilogx'', ''semilogy'' or ''loglog''),', ...
            '''linear'' was assumed!']);
        obj.xlowerbound = 0; obj.xupperbound = 1;
        obj.ylowerbound = 0; obj.yupperbound = 1;
        % set the conversion handle to linear
        obj.conversionHandle = @obj.linearConvert;
        obj.axisType = 'linear';
end

% reset the bounds
bound = [ obj.xlowerbound, obj.xupperbound, obj.ylowerbound, obj.yupperbound];
c = 0;
for q = obj.editabletextcompts.GetObjRef(1:4)
    c = c + 1;
    set(q, 'string', num2str( bound( c ) ) );
end