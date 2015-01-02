function total_earned=run_assesment(Y, names, lambda, grouping, sectors)
clc;
close all;

t0           = 21;
win_size     = 10; % 10 = two weeks
eta          = .01;
plot_comp = true;
plot_plot_vs_prediction = true;
plot_total_earned       = true;
plot_trend_prediction_percentage = true;
plot_omegas = 4;
offset      = 5;

groups  = unique(grouping);
nGroups = numel(groups); 

[T,p] = size(Y);
returns = zeros(T, p);
Y_e_naive = zeros(T, p);
Y_e = zeros(T, p);
Y_e_eta1 = zeros(T, p);
Y_e_eta2 = zeros(T, p);
CI = {};

if plot_omegas 
     figure('Color',[1 1 1]);
end

for t=t0:T
    
    fprintf('T=%g (%g%%)\n', t, t/T);

    % predict on vals from\to
    from = t-win_size;
    to   = t-1;
    [omega, ~, returns(t, :), CI{t-t0+1}, ~, ~] = test2(Y(from:to, :), lambda, eta);

    % naive predition
	[Y_e_naive(t, :), ~,~]= predict_stocks(Y(1:(t-1), :), lambda, 2);   
% 	[Y_e3(t, :), ~,~]= predict_stocks(Y(1:(t-1), :), lambda, 3);   
% 	[Y_e10(t, :), ~,~]= predict_stocks(Y(1:(t-1), :), lambda, 10);   
% 	[Y_e15(t, :), ~,~]= predict_stocks(Y(1:(t-1), :), lambda, 15);   
    
    % plot the first 4 omega matrices
    if t-t0+1-offset<=plot_omegas && t-t0+1 >= offset
        % position subplot
        pos = [.02+(t-t0+1-offset)*(1/(plot_omegas)), .1, 1/(plot_omegas+.5)-.02, .8];
        subplot('Position', pos); 
        
        % plot Linkage matrix
        imagesc(omega);
        title(sprintf('Linkage matrix. T=%g', t));
        
        % cap colors \ color centering 
        colormap (genColorMap('rwb', 20));
        colorbar; 
        caxis([-2 2]); % TODO - double check
    end
end


% Y = log(Y(2:T, :))-log(Y(1:(T-1),:));
% T = T-1;
% Y_e(1,:) = [];

Y_e_eta1(t0:T, :) = Y((t0:T)-1, :).*exp(returns(t0:T, :));

% matColors = distinguishable_colors(p);
matColors = [[141, 211, 199];[ 255, 237, 111];[ 190, 186, 218];...
    [ 251, 128, 114];[ 128, 177, 211];[ 253, 180, 98];...
    [ 179, 222, 105];[ 188, 128, 189];[ 217, 217, 217];...
    [ 252, 205, 229];[ 204, 235, 197];[ 255, 255, 179]]./255;


% plot real values vs prediction
if plot_plot_vs_prediction
for gi=1:nGroups
    stocks = find(grouping==groups(gi));
    
    figure('Color',[1 1 1]);
    subplot(2,1,1);
    hold on;
    
    % plot stocks
    for si=1:numel(stocks)
        plot(1:T, Y(:,stocks(si)),...
            '-',...
             'LineWidth', 4,...
             'markersize', 6,...
             'Color', matColors(si, :));
    end
	ylim([0 max(max(Y(:, stocks)))]);

    % show stock names
    legend(names(stocks));
    
    % Title sector (reverse lookup for sector name because we used hashmap
    sector_names = keys(sectors);
    for secti=1:numel(sector_names)
        if sectors(sector_names{secti}) == groups(gi)
            title(sector_names{secti});
            break;
        end
    end
    

    % plot predictions
    for si=1:numel(stocks)
        plot(t0:T, Y_e(t0:T, stocks(si)),...
            'x',...
             'LineWidth', 2,...
             'markersize', 4,...
             'Color', matColors(si, :));
    end
    
    subplot(2,1,2);
    hold on;
    
    % plot normalized values vs prediction
    % plot stocks
    for si=1:numel(stocks)
        plot(1:T, Y(:,stocks(si))./max(Y(:,stocks(si))),...
            '-',...
             'LineWidth', 4,...
             'markersize', 6,...
             'Color', matColors(si, :));
    end
	ylim([0 1]);

    % show stock names
    legend(names(stocks));

    % plot predictions on top
    for si=1:numel(stocks)
        plot(t0:T, Y_e(t0:T, stocks(si))./max(Y(:,stocks(si))),...
            'x',...
             'LineWidth', 2,...
             'markersize', 4,...
             'Color', matColors(si, :));
    end

end
end

% -- how well did we do? - ignore cost of buying and selling
% buy every time we predict positive return

% all shifts
D = Y(t0:T, :) - Y((t0:T)-1, :);

% Compute total earned along time
total_earned=zeros(1,T);
for t=t0:T
    % Sum the shifts that were bought
    total_earned(t) = total_earned(t-1) + sum( D(t-t0+1, Y_e(t, :) > Y(t-1, :) ));
end

total_earned_naive=zeros(1,T);
for t=t0:T
    % Sum the shifts that were bought
    total_earned_naive(t) = total_earned_naive(t-1) + sum( D(t-t0+1, Y_e_naive(t, :) > Y(t-1, :) ));
end

% plot money earned
if plot_total_earned
    figure('Color',[1 1 1]);
    plot(1:T, total_earned);
    hold on;
    plot(1:T, total_earned_naive);
    xlabel('Time');
    ylabel('Total Earned');
    title('Total earnings in a simplified betting scheme');
    legend({'Exp Smoothing','Naive'});
end

% Count how many times trend was predicted correctly
T = 100; 
D = Y(t0:T, :) - Y((t0:T)-1, :);
trend_predictions = (1/(T-t0))*sum(sign(D) == sign(Y_e(t0:T, :) - Y((t0:T)-1, :)));
trend_predictions_eta1 = (1/(T-t0))*sum(sign(D) == sign(Y_e_eta1(t0:T, :) - Y((t0:T)-1, :)));
trend_predictions_eta2 = (1/(T-t0))*sum(sign(D) == sign(Y_e_eta2(t0:T, :) - Y((t0:T)-1, :)));

trend_predictions_naive = (1/(T-t0))*sum(sign(D) == sign(Y_e_naive(t0:T, :) - Y((t0:T)-1, :)));

if plot_trend_prediction_percentage
    % plot trend prediction percentage exp in different etas 
    %(100 timepoints)
    figure('Color',[1 1 1]);
    bar([trend_predictions(:) trend_predictions_eta1(:) trend_predictions_eta2(:)]);
    legend({'Eta=.1','Eta=.05','Eta=.01'});
    title('Percentage of trends predicted');
    
    % plot trend prediction percentage exp vs naive
    figure('Color',[1 1 1]);
    bar([trend_predictions(:) trend_predictions_naive(:)]);
    legend({'Exp Smoothing','Naive'});
    title('Percentage of trends predicted');
end

for si=1:numel(names)
    fprintf('Trend prediction: %s:%g\n', names{si}, trend_predictions(si));
end

% plot relative error along time
figure('Color',[1 1 1]);
D = abs(Y_e(t0:T,:)-Y(t0:T,:))./Y(t0:T,:);
% D(D>prctile(D(:), 98)) = prctile(D(:), 98); % uncomment if outliers
for gi=1:nGroups
    % plot relative error along time
    pos = [0.05, .05+(gi-1)*(1/(nGroups)), .5, 1/(nGroups+1)-.05];
    subplot('Position', pos); 
    stocks = grouping==groups(gi);
    plot((D(:, stocks)));
    legend(names(stocks));
    ylim([0 .25]);

    % Title sector (reverse lookup for sector name because we used hashmap
    sector_names = keys(sectors);
    for secti=1:numel(sector_names)
        if sectors(sector_names{secti}) == groups(gi)
            title(sector_names{secti});
            break;
        end
    end

    % plot relative error histograms
    pos = [0.65, .05+(gi-1)*(1/(nGroups)), .3, 1/(nGroups+1)-.05];
    subplot('Position', pos); 
    stocks = grouping==groups(gi);
    C = mat2cell(D(:, stocks),size(D(:, stocks),1),ones(1,size(D(:, stocks),2)));
    nhist(C, 'pdf', 'smooth');
    legend(names(stocks));
end

% plot comparison to naive.
D = abs(Y_e(t0:T,:)-Y(t0:T,:))./Y(t0:T,:);
D_eta1 = abs(Y_e_eta1(t0:T,:)-Y(t0:T,:))./Y(t0:T,:);
D_eta2 = abs(Y_e_eta2(t0:T,:)-Y(t0:T,:))./Y(t0:T,:);
D_naive = abs(Y_e_naive(t0:T,:)-Y(t0:T,:))./Y(t0:T,:);

% remove percentiles for plotting without outliers
% D(D>prctile(D(:), 97)) = prctile(D(:), 97);
% D_eta1(D_eta1>prctile(D_eta1(:), 97)) = prctile(D_eta1(:), 97);
% D_eta2(D_eta2>prctile(D_eta2(:), 97)) = prctile(D_eta2(:), 97);
% D_naive(D_naive>prctile(D_naive(:), 99)) = prctile(D_naive(:), 99);


if plot_comp_etas
nComp = 3;

% select stocks where we did better than naive
std([mean(D);mean(D_eta1);mean(D_eta2)])
stocks = [2    18    21];%randsample(p, nComp);
figure('Color',[1 1 1]);
for i=1:nComp
    pos = [0.05, .05+(i-1)*(1/(nComp)), .5, 1/(nComp+1)-.05];
    subplot('Position', pos); 
    plot(([D(:, stocks(i)) D_eta1(:, stocks(i)) D_eta2(:, stocks(i))]), '-');
    legend(strcat(names{stocks(i)}, {' Eta=.01',' Eta=.05', ' Eta=.1'}));
    ylim([0 .1]);

    pos = [0.65, .05+(i-1)*(1/(nComp)), .3, 1/(nComp+1)-.05];
    subplot('Position', pos); 
    C = {D(:, stocks(i)), D_eta1(:, stocks(i)), D_eta2(:, stocks(i))};
    nhist(C, 'pdf', 'smooth');
    legend(strcat(names{stocks(i)}, {' Eta=.01',' Eta=.05', ' Eta=.1'}));
end
end

if plot_comp
nComp = 3;

% select stocks where we did better than naive
if (sum(mean(D) < mean(D_naive)) < nComp)
    fprintf('Number of stocks which less relative error than naive: %g\n', sum(mean(D) < mean(D_naive)));
    stocks = randsample(p, nComp);
else
    stocks = randsample(find(mean(D) < mean(D_naive)), nComp);
end
figure('Color',[1 1 1]);
for i=1:nComp
    pos = [0.05, .05+(i-1)*(1/(nComp)), .5, 1/(nComp+1)-.05];
    subplot('Position', pos); 
    plot(([D(:, stocks(i)) D_naive(:, stocks(i))]));
    legend(strcat(names{stocks(i)}, {' Exp Smoothing',' Naive'}));
    ylim([0 .25]);

    pos = [0.65, .05+(i-1)*(1/(nComp)), .3, 1/(nComp+1)-.05];
    subplot('Position', pos); 
    C = {D(:, stocks(i)), D_naive(:, stocks(i))};
    nhist(C, 'pdf', 'smooth');
    legend(strcat(names{stocks(i)}, {' Exp Smoothing',' Naive'}));
end
end

end