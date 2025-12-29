%
% main_solve_mckyes_parameters_v2.m
% 主脚本文件，用于求解模拟月壤的力学参数 c, phi, delta
% 版本 2: 使用 lsqnonlin 替代 fsolve，更适合处理实验数据拟合问题

clear; clc; close all;

fprintf("--- 开始求解模拟月壤力学参数 (v2) ---\n");

% 1. 定义常数
w = 0.05;       % m (竖板宽度，请根据实际情况修改)
gamma = 1.64 * 1000; % kg/m^3 (模拟月壤密度)
g = 9.81;       % m/s^2 (重力加速度)

constants.w = w;
constants.gamma = gamma;
constants.g = g;

fprintf("常数设置：\n");
fprintf("  竖板宽度 (w): %.4f m\n", w);
fprintf("  模拟月壤密度 (gamma): %.2f kg/m^3\n", gamma);
fprintf("  重力加速度 (g): %.2f m/s^2\n", g);

% 2. 实验数据 (d: m, v: m/s, T_measured: N)
% 对每组重复实验的 T 值取平均
data_points = [
    0.03, 0.001, mean([8.4, 8.5, 9.6]);
    0.04, 0.001, mean([24.1, 24.3, 27.9]);
    0.05, 0.001, mean([37.6, 47.1, 28.3]);
];

fprintf("\n使用的实验数据点 (d(m), v(m/s), T_measured(N))：\n");
disp(data_points);

% 3. 初始猜测值 [c, phi, delta] 和参数边界
% c: 内聚力 (Pa), phi: 内摩擦角 (rad), delta: 机-土摩擦角 (rad)
c0 = 100;           % Pa (初始猜测值调整为较小值)
phi0 = deg2rad(30); % rad (30度)
delta0 = deg2rad(20);% rad (phi的2/3左右)
x0 = [c0, phi0, delta0];

% 设置参数的下界和上界 [c_lb, phi_lb, delta_lb] 和 [c_ub, phi_ub, delta_ub]
lb = [0, deg2rad(10), deg2rad(5)];      % 下界：c>=0, phi>=10度, delta>=5度
ub = [5000, deg2rad(60), deg2rad(45)]; % 上界：c<=5kPa, phi<=60度, delta<=45度

fprintf("\n初始猜测值：\n");
fprintf("  c0: %.2f Pa, phi0: %.2f rad, delta0: %.2f rad\n", c0, phi0, delta0);

% 4. 使用 lsqnonlin 求解非线性最小二乘问题
options = optimoptions("lsqnonlin", "Display", "iter");

fprintf("\n--- 运行 lsqnonlin 求解 ---\n");
[x_solution, resnorm, residual, exitflag, output] = lsqnonlin(@(x) equations_to_solve(x, data_points, constants), x0, lb, ub, options);

% 5. 显示求解结果
if exitflag > 0
    c_solved = x_solution(1);
    phi_solved = x_solution(2);
    delta_solved = x_solution(3);
    
    fprintf("\n--- 求解成功！ ---\n");
    fprintf("求解出的参数：\n");
    fprintf("  内聚力 (c): %.4f Pa (%.4f kPa)\n", c_solved, c_solved/1000);
    fprintf("  内摩擦角 (phi): %.4f 弧度 (%.2f 度)\n", phi_solved, rad2deg(phi_solved));
    fprintf("  机-土摩擦角 (delta): %.4f 弧度 (%.2f 度)\n", delta_solved, rad2deg(delta_solved));
    fprintf("  残差平方和 (resnorm): %.4e\n", resnorm);
    
    % 6. 结果验证
    fprintf("\n--- 结果验证 ---\n");
    fprintf("  比较实测T值与理论计算T值：\n");
    fprintf(" d (mm) | v (mm/s) | T_measured (N) | T_calculated (N) | Error (%%)\n");
    fprintf("------------------------------------------------------------------------\n");
    for i = 1:size(data_points, 1)
        d_val = data_points(i, 1);
        v_val = data_points(i, 2);
        T_measured = data_points(i, 3);
        
        T_calculated = mckyes_T(c_solved, phi_solved, delta_solved, constants.w, constants.gamma, constants.g, d_val, v_val);
        
        fprintf(" %6.1f | %8.1f | %14.3f | %16.3f | %7.2f\n", ...
            d_val*1000, v_val*1000, T_measured, T_calculated, abs(T_calculated - T_measured)/T_measured * 100);
    end
else
    fprintf("\n--- 求解失败！ ---\n");
    fprintf("Exit Flag: %d\n", exitflag);
    fprintf("Output Message: %s\n", output.message);
end

fprintf("--- 求解过程结束 ---\n");


