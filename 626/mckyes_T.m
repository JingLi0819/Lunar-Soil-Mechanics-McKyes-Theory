
function T = mckyes_T(c, phi, delta, w, gamma, g, d, v)
% mckyes_T.m
% 计算 Mckyes 理论中的水平阻力 T
% 输入：
%   c: 内聚力 (Pa)
%   phi: 内摩擦角 (rad)
%   delta: 机-土摩擦角 (rad)
%   w: 竖板宽度 (m)
%   gamma: 模拟月壤密度 (kg/m^3)
%   g: 重力加速度 (m/s^2)
%   d: 入土深度 (m)
%   v: 水平平推速度 (m/s)
% 输出：
%   T: 水平阻力 (N)

% 确保角度在合理范围内，避免 tan/cot 出现奇异值
phi = max(1e-6, min(phi, pi/2 - 1e-6)); % 0 < phi < pi/2
delta = max(1e-6, min(delta, pi/2 - 1e-6)); % 0 < delta < pi/2

% 计算 rho (式2)
rho = (pi/4) - (phi/2);

% 计算 E (式2)
E = cos(pi/4 + delta) + sin(pi/4 + delta) * cot(rho + phi);

% 避免除以零
if abs(E) < 1e-9
    T = inf; % 返回无穷大表示计算失败
    return;
end

% 计算 Nc, Ngamma, Na (式2)
Ngamma = 0.5 * cot(rho) / E;
Nc = (1 + cot(rho) * cot(rho + phi)) / E;
Na = (tan(rho) + cot(rho + phi)) / E;

% 计算水平阻力 T (式1)
% 注意：gamma * g 才是重度 (N/m^3)
% T = w * (gamma * g * d^2 * Ngamma + c * d * Nc + gamma * v^2 * d * Na);
% 修正：根据图片中的公式1，gamma是密度，所以gamma*g是重度。但公式中直接写了gamma。
% 结合表2，gamma是模拟月壤容重（密度），单位kg/m^3。所以公式1中的gamma*d^2*Ngamma项
% 应该是 (gamma * g) * d^2 * Ngamma，即重度乘以d^2。
% 但如果按照图片公式1原样，gamma就是密度，那么第一项的物理意义是密度*g*d^2*Ngamma
% 这里我们严格按照公式1来，即gamma就是密度，Ngamma等系数已经包含了重力加速度的影响
% 重新审视公式1和表2，表2中gamma是容重（密度），单位kg/m^3。g是m/s^2。
% 那么公式1中的gamma*d^2*Ngamma这一项，如果gamma是密度，则需要乘以g才能变成重度。
% 但是Mckyes公式通常是使用重度（unit weight）而不是密度。
% 考虑到表2中gamma的单位是kg/m^3，g是m/s^2，这里将gamma*g作为重度。

T = w * ((gamma * g) * d^2 * Ngamma + c * d * Nc + gamma * v^2 * d * Na);

end


