%% unit testing for spmup_realign_qa

close all;

%% get data
test_data_folder = fullfile(test_folder(), 'data');

time_series = spm_select('FPlistRec', test_data_folder, '^sub.*bold.nii');

plot_figures = 'off';

%%
new_files = spmup_realign_qa(time_series, ...
                             'Motion Parameters', 'off', ...
                             'Framewise displacement', 'off', ...
                             'Globals', 'off', ...
                             'Voltera', 'off', ...
                             'Movie', 'off', ...
                             'figure', plot_figures);

assert(isempty(new_files));

%% Motion
new_files = spmup_realign_qa(time_series, ...
                             'Motion Parameters', 'on', ...
                             'Framewise displacement', 'off', ...
                             'Globals', 'off', ...
                             'Voltera', 'off', ...
                             'Movie', 'off', ...
                             'figure', plot_figures);

assert(isempty(new_files));

%% FD
new_files = spmup_realign_qa(time_series, ...
                             'Motion Parameters', 'off', ...
                             'Framewise displacement', 'on', ...
                             'Globals', 'off', ...
                             'Voltera', 'off', ...
                             'Movie', 'off', ...
                             'figure', plot_figures);

% 6 motion + FD + RMS + 3 censoring regressors
motion_and_fd_censor = spm_load(new_files{1});
assert(size(motion_and_fd_censor, 2) == 11);
% make sure all censoring regressors are at the end
assert(all(sum(all_regressors(:, end - 2:end)) == [1 1 1]));

teardown(new_files);

%% Voltera
new_files = spmup_realign_qa(time_series, ...
                             'Motion Parameters', 'off', ...
                             'Framewise displacement', 'off', ...
                             'Globals', 'off', ...
                             'Voltera', 'on', ...
                             'Movie', 'off', ...
                             'figure', plot_figures);

% 6 motion + their derivatives + square of each
voltera = spm_load(new_files{1});
assert(size(voltera, 2) == 24);

teardown(new_files);

%% Globals
new_files = spmup_realign_qa(time_series, ...
                             'Motion Parameters', 'off', ...
                             'Framewise displacement', 'off', ...
                             'Globals', 'on', ...
                             'Voltera', 'off', ...
                             'Movie', 'off', ...
                             'figure', plot_figures);

% 6 motion + one global regressor
globals = spm_load(new_files{1});
assert(size(globals, 2) == 7);

teardown(new_files);

%% all together
new_files = spmup_realign_qa(time_series, ...
                             'Motion Parameters', 'on', ...
                             'Framewise displacement', 'on', ...
                             'Globals', 'on', ...
                             'Voltera', 'on', ...
                             'Movie', 'off', ...
                             'figure', plot_figures);

% 24 voltera + RMS + FD + global + 3 censoring regressors
all_regressors = spm_load(new_files{1});
assert(size(all_regressors, 2) == 30);
% make sure all censoring regressors are at the end
assert(all(sum(all_regressors(:, end - 2:end)) == [1 1 1]));

teardown(new_files);

%%
function teardown(new_files)
    delete(new_files{1});
    delete(fullfile(test_folder(), 'data', 'sub-01', 'func', '*.ps'));
end
