function F = equations_to_solve(x, data_points, constants)
% equations_to_solve.m
% fsolve 的目标函数，构建非线性方程组
% 输入：
%   x: 待求解的参数向量 [c, phi, delta]
%   data_points: 实验数据 [d, v, T_measured]
%   constants: 包含 w, gamma, g 的结构体
% 输出：
%   F: 残差向量，每个元素是 T_calculated - T_measured

c = x(1);    % 内聚力 (Pa)
phi = x(2);  % 内摩擦角 (rad)
delta = x(3);% 机-土摩擦角 (rad)

w = constants.w;
gamma = constants.gamma;
g = constants.g;

num_data_points = size(data_points, 1);
F = zeros(num_data_points, 1);

% 对参数进行物理合理性约束
% 内聚力 c 必须非负
if c < 0
    F = ones(num_data_points, 1) * 1e10; % 返回一个很大的误差
    return;
end

% 摩擦角 phi 和 delta 必须在 (0, pi/2) 范围内
% 并且 phi 应该大于 delta (通常情况下)
if phi <= 0 || phi >= pi/2 || delta <= 0 || delta >= pi/2 || delta > phi
    F = ones(num_data_points, 1) * 1e10; % 返回一个很大的误差
    return;
end

% 遍历每个数据点，计算残差
for i = 1:num_data_points
    d_measured = data_points(i, 1);
    v_measured = data_points(i, 2);
    T_measured = data_points(i, 3);
    
    % 调用 mckyes_T 函数计算理论水平阻力
    T_calculated = mckyes_T(c, phi, delta, w, gamma, g, d_measured, v_measured);
    
    % 计算残差
    F(i) = T_calculated - T_measured;
end

end


