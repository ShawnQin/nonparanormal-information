% Figure 3
close all;
clear;
num_trials = 400;
% ns = [round(logspace(1.5, 2 - 1/9, 8)) round(logspace(2, 3, 10))];
ns = round(logspace(1.5, 3, 18)); % should be 4, 18
% p_funs = {@(n) n^(1/4)};
p_funs = {@(n) 25};
Sigma_funs = {@(p) corrcov(wishrnd(eye(p), 10*p))};
transforms = {@(Xs) Xs};
estimators = {@(Xs) normal_info(Xs), ...
              @(Xs) nonparanormal_info(Xs), ...
              @(Xs) nonparanormal_Spearman_info(Xs), ...
              @(Xs) nonparanormal_Kendall_info(Xs), ...
              @(Xs) KNN_info(Xs)};

[results, std_errs] = ...
  test(estimators, ns, p_funs, Sigma_funs, transforms, num_trials);

columnwidth = 8.25381;
fig = figure('units', 'centimeters', 'position', [5 5 columnwidth 6]);
hold all;
colorOrder = get(gca, 'ColorOrder');
for estimator_idx = 1:length(estimators)
  means = squeeze(results(:, 1, 1, 1, estimator_idx));
  CIs = 1.96 * squeeze(std_errs(:, 1, 1, 1, estimator_idx)); % 95% asymptotic confidence interval radius
  lower = log10(means) - log10(means - CIs);
  upper = log10(means + CIs) - log10(means);
  color = colorOrder(mod(length(get(gca, 'Children')), size(colorOrder, 1))+1, :);
  % errorbar(log10(ns), log10(means), lower, upper, 'LineWidth', 1.5);
  legendPlots(estimator_idx) = plot(log10(ns), log10(means), 'LineWidth', 1.5);
  legendPlots(estimator_idx).Marker = get_next_marker(estimator_idx);
end
xlim([0.95*log10(min(ns)) 1.02*log10(max(ns))]);
xlabel('Sample Size $$(\log_{10}(n))$$', 'FontSize', 12, 'Interpreter', 'latex');
ylabel('$$\log_{10}$$(MSE)', 'FontSize', 14, 'Interpreter', 'latex');
legend(legendPlots, {'$$\hat I$$', ...
                     '$$\hat I_G$$', ...
                     '$$\hat I_\rho$$', ...
                     '$$\hat I_\tau$$', ...
                     '$$\hat I_{KNN}$$'}, ...
              'Location', 'northeast', ...
              'Interpreter', 'latex', ...
              'FontSize', 12);
fig.PaperUnits = 'centimeters';
fig.PaperPosition = [5 5 columnwidth 6];
saveas(fig, 'figs/fig3_hard.fig');
saveas(fig, 'figs/fig3_hard.png');
saveas(fig, 'figs/fig3_hard.eps', 'epsc2');