function [ s ] = code2structname(string, type)
switch type
    case '50ETFOption'
        s = strcat('OPT', string(1:8));
    case 'F'
        if length(string) == 8
            s = [string(1:4) string(end-2:end)];
        elseif length(string) == 10
            s = [string(1:6) string(end-2:end)];
        end
    case 'S'
        s = [string(8:9) string(1:6)];
    case 'CommodityOption'
        s = string;
    otherwise
        disp('other value')
end
end

