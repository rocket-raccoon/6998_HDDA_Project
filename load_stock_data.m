function [Y names]=load_stock_data()
    
files = uipickfiles('num',[1 inf],'out','cell', 'FilterSpec', ['*.csv']);
if isequal(files,0) ~=0
    return 
end

tic;
fids = cellfun(@(f) fopen(f, 'r'), files, 'UniformOutput', false);  %opening files
csvheaders = cellfun(@(f) fgetl(f), fids, 'UniformOutput', false);   %readinf first line in file
cellfun(@(f) fclose(f), fids, 'UniformOutput', false);  %closing files

% %Convert  header to cell array
% csvheaders = cellfun(@(h) regexp(h, '([^,]*)', 'tokens'), csvheaders, 'UniformOutput', false);
% csvheaders = cellfun(@(h) cat(2, h{:}), csvheaders, 'UniformOutput', false);


%Read in data    
csvdats = cellfun(@(fname) csvread(fname, 1,1), files, 'UniformOutput', false);

%Add data to session
disp(sprintf('Files loaded: %gs',toc));


d=500;
Y=zeros(d, 0);
names = {};
for ci=1:numel(csvdats)
    Y(:, end+1) = csvdats{ci}(1:d, 1);
    [~, filename, ~] = fileparts(files{ci}); 
    names{end+1} = filename;
end

Y = Y(end:-1:1, :); % make time ascending

% Y=cell2mat(csvdats);
% Y = Y(:, 1:5:end);
end