%
% plot_results.m
% 用于绘制实验数据和求解结果的脚本
%

clear; clc; close all;

% 1. 定义常数 (与 main_solve_mckyes_parameters.m 保持一致)
w = 0.05;       % m
gamma = 1.64 * 1000; % kg/m^3
g = 9.81;       % m/s^2

constants.w = w;
constants.gamma = gamma;
constants.g = g;

% 2. 实验数据 (与 main_solve_mckyes_parameters.m 保持一致)
data_points = [
    0.03, 0.001, mean([8.4, 8.5, 9.6]);
    0.04, 0.001, mean([24.1, 24.3, 27.9]);
    0.05, 0.001, mean([37.6, 47.1, 28.3]);
];

% 3. 假设已经求解出的参数 (这里使用示例值，实际应从 main_solve_mckyes_parameters.m 运行结果中获取)
% 为了能够独立运行此绘图脚本，这里假设一些求解出的参数。
% 在实际使用中，您应该运行 main_solve_mckyes_parameters.m 得到这些值。
% 这里的示例值是根据经验设置的，用于确保绘图脚本可以独立运行。
% 实际运行时，请将 main_solve_mckyes_parameters.m 运行后的 c_solved, phi_solved, delta_solved 赋值到这里。

c_solved = 100; % Pa (示例值)
phi_solved = deg2rad(30); % rad (示例值)
delta_solved = deg2rad(20); % rad (示例值)

% 4. 绘制 T-d 曲线
figure;
hold on;

% 绘制实测数据点
plot(data_points(:, 1) * 1000, data_points(:, 3), 'o', 'MarkerSize', 8, 'LineWidth', 1.5, 'DisplayName', '实测数据 (v=1mm/s)');

% 绘制理论曲线
d_plot = linspace(0.02, 0.06, 100); % 生成一系列入土深度值用于绘图
T_theoretical = zeros(size(d_plot));
for i = 1:length(d_plot)
    T_theoretical(i) = mckyes_T(c_solved, phi_solved, delta_solved, w, gamma, g, d_plot(i), 0.001); % v=1mm/s
end
plot(d_plot * 1000, T_theoretical, '-', 'LineWidth', 1.5, 'DisplayName', 'Mckyes 理论曲线 (v=1mm/s)');

xlabel('入土深度 d (mm)');
ylabel('水平阻力 T (N)');
title('水平阻力 T 与入土深度 d 的关系');
legend('Location', 'best');
grid on;
box on;
set(gca, 'FontSize', 12);

% 5. 绘制参数分布图 (示例：如果有多组实验数据和求解结果，可以绘制参数的箱线图或直方图)
% 由于目前只有一组求解结果，这里简单展示参数值。
% 如果有多次实验和求解，可以将每次求解的 c, phi, delta 存储起来，然后绘制分布。

figure;
bar_data = [c_solved/1000, rad2deg(phi_solved), rad2deg(delta_solved)];
bar(bar_data);
set(gca, 'XTickLabel', {'内聚力 c (kPa)', '内摩擦角 \phi (度)', '机-土摩擦角 \delta (度)'});
ylabel('值');
title('求解出的力学参数');
grid on;
box on;
set(gca, 'FontSize', 12);

fprintf('绘图脚本运行完毕。请查看生成的图窗。\n');


