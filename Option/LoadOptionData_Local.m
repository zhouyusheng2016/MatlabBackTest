function [TDB flag] = LoadOptionData_Local(w, filename,start_time,end_time,underlyingCode,Options)
% 期权数据导入
delimiter = ',';
startRow = 2;
formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fileID);
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));
for col=[3,4,5,7,8,9,10,11,12,13,14,15,16,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40]
    % Converts text in the input cell array to numbers. Replaced non-numeric
    % text with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1)
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData(row), regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if numbers.contains(',')
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(numbers, thousandsRegExp, 'once'))
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric text to numbers.
            if ~invalidThousandsSeparator
                numbers = textscan(char(strrep(numbers, ',', '')), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch
            raw{row, col} = rawData{row};
        end
    end
end
dateFormatIndex = 1;
blankDates = cell(1,size(raw,2));
anyBlankDates = false(size(raw,1),1);
invalidDates = cell(1,size(raw,2));
anyInvalidDates = false(size(raw,1),1);
for col=[1,17]% Convert the contents of columns with dates to MATLAB datetimes using the specified date format.
    try
        dates{col} = datetime(dataArray{col}, 'Format', 'yyyy/MM/dd', 'InputFormat', 'yyyy/MM/dd'); %#ok<SAGROW>
    catch
        try
            % Handle dates surrounded by quotes
            dataArray{col} = cellfun(@(x) x(2:end-1), dataArray{col}, 'UniformOutput', false);
            dates{col} = datetime(dataArray{col}, 'Format', 'yyyy/MM/dd', 'InputFormat', 'yyyy/MM/dd'); %#ok<SAGROW>
        catch
            dates{col} = repmat(datetime([NaN NaN NaN]), size(dataArray{col})); %#ok<SAGROW>
        end
    end
    
    dateFormatIndex = dateFormatIndex + 1;
    blankDates{col} = dataArray{col} == '';
    anyBlankDates = blankDates{col} | anyBlankDates;
    invalidDates{col} = isnan(dates{col}.Hour) - blankDates{col};
    anyInvalidDates = invalidDates{col} | anyInvalidDates;
end
dates = dates(:,[1,17]);
blankDates = blankDates(:,[1,17]);
invalidDates = invalidDates(:,[1,17]);
rawNumericColumns = raw(:, [3,4,5,7,8,9,10,11,12,13,14,15,16,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40]);
rawStringColumns = string(raw(:, [2,6]));
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
rawNumericColumns(R) = {NaN}; % Replace non-numeric cells
for catIdx = [1,2]
    idx = (rawStringColumns(:, catIdx) == "<undefined>");
    rawStringColumns(idx, catIdx) = "";
end
OptionDataTable = table;
OptionDataTable.Expiration = dates{:, 1};
OptionDataTable.OptionType = categorical(rawStringColumns(:, 1));
OptionDataTable.code = cell2mat(rawNumericColumns(:, 1));
OptionDataTable.Strike = cell2mat(rawNumericColumns(:, 2));
OptionDataTable.date = cell2mat(rawNumericColumns(:, 3));
OptionDataTable.OptionSymbol = categorical(rawStringColumns(:, 2));
OptionDataTable.open = cell2mat(rawNumericColumns(:, 4));
OptionDataTable.high = cell2mat(rawNumericColumns(:, 5));
OptionDataTable.low = cell2mat(rawNumericColumns(:, 6));
OptionDataTable.Last = cell2mat(rawNumericColumns(:, 7));
OptionDataTable.Volume = cell2mat(rawNumericColumns(:, 8));
OptionDataTable.OpenInterest = cell2mat(rawNumericColumns(:, 9));
OptionDataTable.turnover = cell2mat(rawNumericColumns(:, 10));
OptionDataTable.contractunit = cell2mat(rawNumericColumns(:, 11));
OptionDataTable.UnderlyingSymbol = cell2mat(rawNumericColumns(:, 12));
OptionDataTable.UnderlyingPrice = cell2mat(rawNumericColumns(:, 13));
OptionDataTable.QuoteDatetime = dates{:, 2};
OptionDataTable.DaysUntilExpiration = cell2mat(rawNumericColumns(:, 14));
OptionDataTable.TimeUntilExpiration = cell2mat(rawNumericColumns(:, 15));
OptionDataTable.InterestRate = cell2mat(rawNumericColumns(:, 16));
OptionDataTable.ImpliedVolatilityLast = cell2mat(rawNumericColumns(:, 17));
OptionDataTable.ImpliedVolatilitynotInterp = cell2mat(rawNumericColumns(:, 18));
OptionDataTable.TheorealValue = cell2mat(rawNumericColumns(:, 19));
OptionDataTable.Delta = cell2mat(rawNumericColumns(:, 20));
OptionDataTable.Gamma = cell2mat(rawNumericColumns(:, 21));
OptionDataTable.Vega = cell2mat(rawNumericColumns(:, 22));
OptionDataTable.Theta = cell2mat(rawNumericColumns(:, 23));
OptionDataTable.Rho = cell2mat(rawNumericColumns(:, 24));
OptionDataTable.ModelError = cell2mat(rawNumericColumns(:, 25));
OptionDataTable.hv10 = cell2mat(rawNumericColumns(:, 26));
OptionDataTable.hv20 = cell2mat(rawNumericColumns(:, 27));
OptionDataTable.hv30 = cell2mat(rawNumericColumns(:, 28));
OptionDataTable.hv60 = cell2mat(rawNumericColumns(:, 29));
OptionDataTable.hv90 = cell2mat(rawNumericColumns(:, 30));
OptionDataTable.hv120 = cell2mat(rawNumericColumns(:, 31));
OptionDataTable.hv150 = cell2mat(rawNumericColumns(:, 32));
OptionDataTable.hv180 = cell2mat(rawNumericColumns(:, 33));
OptionDataTable.lx = cell2mat(rawNumericColumns(:, 34));
OptionDataTable.futurecode = cell2mat(rawNumericColumns(:, 35));
OptionDataTable.futureclose = cell2mat(rawNumericColumns(:, 36));
clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData...
    rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp ...
    dateFormatIndex dates blankDates anyBlankDates invalidDates anyInvalidDates ...
    rawNumericColumns rawStringColumns R catIdx idx;
OptionDataTable = sortrows(OptionDataTable,'date','ascend');%日期排序


% 截取时间数据
start_datenum = datenum(start_time, 'yyyy-mm-dd');
end_datenum = datenum(end_time, 'yyyy-mm-dd');
optionDataDatenum = datenum(num2str(OptionDataTable.date),'yyyymmdd');
cond1 = optionDataDatenum>=start_datenum;
cond2 = optionDataDatenum<=end_datenum;
OptionDataTable = OptionDataTable(cond1 & cond2,:);
OptionDataTable = sortrows(OptionDataTable,'date','ascend');%日期排序
w_wsd_times_0 =unique(datenum(num2str(OptionDataTable.date),'yyyymmdd'));
timeLength = length(w_wsd_times_0);
% 构建期权代码引索表
codes = unique(OptionDataTable.code);
%设置游标
TDB = struct;
for code = codes'
    idx_code_opt = OptionDataTable.code == code;
    thisOpt = OptionDataTable(idx_code_opt,:);
    thisOpt = sortrows(thisOpt,'date','ascend');%日期排序
   
    dataTime = datenum(num2str(thisOpt.date),'yyyymmdd');
    DB.Times = w_wsd_times_0;
    DB.TimesStr = datestr(w_wsd_times_0,'yymmdd');%按年月日格式的时间戳（交易日）
    [~,idx_haveData,~] = intersect(w_wsd_times_0,dataTime);
    % 期权合约信息
    structName = code2structname(num2str(code), 'O');
    DB.Code =  num2str(code);
    %记录C/P 到期日 标的代码
    DB.Info = {thisOpt.OptionType(1) thisOpt.Expiration(1) thisOpt.UnderlyingSymbol(1)};
    % 期权行情信息
    DB.Open = nan(timeLength,1);
    DB.Open(idx_haveData) = thisOpt.open;%开
    DB.High = nan(timeLength,1);
    DB.High(idx_haveData) = thisOpt.high;%高
    DB.Low = nan(timeLength,1);
    DB.Low(idx_haveData) = thisOpt.low;%低
    DB.Close = nan(timeLength,1);
    DB.Close(idx_haveData) = thisOpt.Last;%收
    DB.Volume = nan(timeLength,1);
    DB.Volume(idx_haveData) = thisOpt.Volume;%量
    % 期权行权价格
    DB.Strike = nan(timeLength,1);
    DB.Strike(idx_haveData) = thisOpt.Strike;
    % 期权符号
    DB.Symbol = cell(timeLength,1);
    DB.Symbol(idx_haveData,:) = cellstr(thisOpt.OptionSymbol);
    % 期权合约乘数
    DB.ContractUnit = nan(timeLength,1);
    DB.ContractUnit(idx_haveData) = thisOpt.contractunit;
    % 期权
    % 期权其他信息
    DB.OpenInterest = nan(timeLength,1);
    DB.DaysUntilExpiration = nan(timeLength,1);
    DB.TimeUntilExpiration = nan(timeLength,1);
    DB.InterestRate = nan(timeLength,1);
    DB.ImpliedVolatilityLast = nan(timeLength,1);
    DB.Delta = nan(timeLength,1);
    DB.Gamma = nan(timeLength,1);
    DB.Vega = nan(timeLength,1);
    DB.Theta = nan(timeLength,1);
    DB.hv10 = nan(timeLength,1);
    DB.hv20 = nan(timeLength,1);
    DB.hv30 = nan(timeLength,1);
    DB.hv60 = nan(timeLength,1);
    DB.hv90 = nan(timeLength,1);
    DB.hv120 = nan(timeLength,1);
    DB.hv150 = nan(timeLength,1);
    DB.hv180 = nan(timeLength,1);
    
    DB.OpenInterest(idx_haveData) = thisOpt.OpenInterest;
    DB.DaysUntilExpiration(idx_haveData)= thisOpt.DaysUntilExpiration;
    DB.TimeUntilExpiration(idx_haveData)= thisOpt.TimeUntilExpiration;
    DB.InterestRate(idx_haveData)= thisOpt.InterestRate;
    DB.ImpliedVolatilityLast(idx_haveData)= thisOpt.ImpliedVolatilityLast;
    DB.Delta(idx_haveData)= thisOpt.Delta;
    DB.Gamma(idx_haveData)= thisOpt.Gamma;
    DB.Vega(idx_haveData)= thisOpt.Vega;
    DB.Theta(idx_haveData)= thisOpt.Theta;
    DB.hv10(idx_haveData)= thisOpt.hv10;
    DB.hv20(idx_haveData)= thisOpt.hv20;
    DB.hv30(idx_haveData)= thisOpt.hv30;
    DB.hv60(idx_haveData)= thisOpt.hv60;
    DB.hv90(idx_haveData)= thisOpt.hv90;
    DB.hv120(idx_haveData)= thisOpt.hv120;
    DB.hv150(idx_haveData)= thisOpt.hv150;
    DB.hv180(idx_haveData)= thisOpt.hv180;
    DB.Trade_status = zeros(timeLength,1);
    DB.Trade_status(idx_haveData) = 1;
    DB.NK = length(DB.Open);%行情数据量
    
    TDB=setfield(TDB,structName,DB);
end
TDB.Times = w_wsd_times_0;
TDB.TimesStr = datestr(w_wsd_times_0,'yymmdd');%按年月日格式的时间戳（交易日）

%加载期权underlying Asset的数据
% 行情数据
[w_wsd_data_0,w_wsd_codes_0,w_wsd_fields_0,w_wsd_times_0,w_wsd_errorid_0,w_wsd_reqid_0]= ...
    w.wsd(underlyingCode,'open,high,low,close,volume,vwap,pre_close',start_time,end_time,'PriceAdj=F');
if w_wsd_errorid_0~=0
    disp(['!!! 加载' windcode '行情数据错误: ' w_wsd_data_0{1} ' Code: ' num2str(w_wsd_errorid_0) ' !!!']);
    flag=0;
    return;
end
Underlying.Times = w_wsd_times_0;
Underlying.TimesStr = datestr(w_wsd_times_0,'yymmdd');
Underlying.Open = w_wsd_data_0(:,1);
Underlying.High = w_wsd_data_0(:,2);
Underlying.Low = w_wsd_data_0(:,3);
Underlying.Close = w_wsd_data_0(:,4);
Underlying.Volume = w_wsd_data_0(:,5);
Underlying.Vwap = w_wsd_data_0(:,6);
Underlying.PreClose = w_wsd_data_0(:,7);
TDB=setfield(TDB,'Underlying',Underlying);
TDB.CurrentK = 1;
TDB.NK = length(Underlying.Times);

%数据加载成功
flag=1;