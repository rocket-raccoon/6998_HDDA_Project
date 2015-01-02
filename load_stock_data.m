function [Y, stocknames, grouping, fmap]=load_stock_data(data_dir)
% Y - data
% names - file name (assuming that is the stock ticker name)
% grouping - an array grouping stocks by folder

d=500;          % data entries to compile
Y=zeros(d, 0);  % output variable for numerical data 
stocknames = {};     % output variable for ticker name per stock
grouping = [];  % output variable for sector grouping per stock
fmap = containers.Map; % maps sector grouping to sector name

if nargin==0
    % get user selected files
    files = uipickfiles('num',[1 inf],'out','cell', 'FilterSpec', ['*.csv']);
    if isequal(files,0) ~=0
        return 
    else 
        new_files    = {};
        remove_dirs = [];
        % if any of the files are folder - replace them with inner contents
        for f=1:numel(files)
            if isdir(files{f})
                contents = getFilesFromDirectory(files{f});
                nfiles = numel(contents);
                new_files(end+1:end+nfiles) = contents;
                remove_dirs(end+1) = f;
            end
        end
        files(remove_dirs) = [];
        files(end+1:end+numel(new_files)) = new_files;   
    end
else
    files = {};
    % get sector directories
    sectors = getFilesInDirectory(data_dir);
    
    % get data files per sector folder
    for sector=1:numel(sectors)
        stock_files = getFilesInDirectory(sectors{sector});
        files(end+1:end+numel(stock_files)) = stock_files;   
    end
end

%Read in data    
tic;
csvdats = cellfun(@(fname) csvread(fname, 1,1), files, 'UniformOutput', false);
disp(sprintf('Files loaded: %gs',toc));

% group stocks by originating folder name - prepare folder name hash map   
[foldername,~, ~] = fileparts(files{1});
[~,sector, ~] = fileparts(foldername);
fmap(sector) = 1;

% foreach file copy the "d" length data, name, and grouping number
for ci=1:numel(csvdats)
    
    % read data
    Y(:, end+1) = csvdats{ci}(1:d, 1);

    [foldername, filename, ~] = fileparts(files{ci}); 
    [~, sector, ~] = fileparts(foldername); 

    % name of stock ticker
    stocknames{end+1} = filename;
    
    % place a grouping per folder name
    if ~isKey(fmap,sector)
        g = max(grouping)+1;
        fmap(sector) = g;
    else
        g = fmap(sector);
    end
    grouping(end+1) = g;
end

% reverse order 
Y = Y(end:-1:1, :); % make time ascending

end

function files=getFilesInDirectory(data_dir)
    tmp = struct2cell(dir([data_dir filesep '*.csv']));
    new_filenames = tmp(1,:);
    files = strcat({[data_dir filesep]},new_filenames);
end