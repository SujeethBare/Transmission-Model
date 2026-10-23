
drive = readmatrix('UDDS.csv');
Tsim  = drive(end,1);

% Motor efficiency map
Meff        = readmatrix("Nissan Leaf Motor Controller Efficiency.csv");
Meff_Speed  = Meff(:,1);
Meff_eff    = Meff(:,2:16);
Meff_Torque = Meff(1:size(Meff_eff,2), 17);

% Reduced efficiency points
MDP        = readmatrix("Motor Efficiency Data Less Points.csv");
MDP_Speed  = MDP(:,1);
MDP_Torque = MDP(:,2);
MDP_eff    = MDP(:,3);

% Motor torque envelope
Motor         = readmatrix('Nissan Leaf MC.csv');
Motor_Speed   = Motor(:,1);
Motor_Ptorque = Motor(:,2);
Motor_Ctorque = Motor(:,3);

%% ===================== SIMULATION =====================
out = sim('Powertrain_2GR.slx', Tsim);

M_Speed = out.Motor_Speed.Data;
T_GR1   = out.Motor_Torq_GR1.Data;
T_GR2   = out.Motor_Torq_GR2.Data;
M_Eff   = out.Motor_Efficiency.Data * 100;     % fraction -> %

% Keep only points where each gear is actually active
idx1 = T_GR1 ~= 0;
idx2 = T_GR2 ~= 0;

%% ========== FIGURE 1: MOTOR CHARACTERISTICS GRAPH ==========
figure('Name','Motor Characteristics graph'); hold on; box on;

% Torque envelope
plot(Motor_Speed, Motor_Ptorque, 'r', 'HandleVisibility','off');
plot(Motor_Speed, Motor_Ctorque, 'g', 'HandleVisibility','off');
text(1000, 280, 'Motor Peak Torque');
text(1000, 155, 'Motor Continuous Torque');

% Operating points
scatter(M_Speed(idx1), T_GR1(idx1), 15, 'b', 'DisplayName', 'GR1');
scatter(M_Speed(idx2), T_GR2(idx2), 15, 'm', 'DisplayName', 'GR2');

% Efficiency points with labels
scatter(MDP_Speed, MDP_Torque, 10, 'r', 'filled', 'HandleVisibility','off');
text(MDP_Speed, MDP_Torque, num2str(MDP_eff*100), 'FontSize', 8);

xlabel('Motor Speed (rpm)');
ylabel('Motor Torque (Nm)');
title('Motor Operating Region - UDDS (2-Speed)');
xlim([0 10000]); ylim([0 300]);
legend('show', 'Location', 'northeast');

%% ============= FIGURE 2: MOTOR EFFICIENCY MAP =============
figure('Name','Motor efficiency map'); hold on;

surf(Meff_Speed, Meff_Torque, Meff_eff', 'HandleVisibility','off');

scatter3(M_Speed(idx1), T_GR1(idx1), M_Eff(idx1), 15, 'b', 'DisplayName', 'GR1');
scatter3(M_Speed(idx2), T_GR2(idx2), M_Eff(idx2), 15, 'm', 'DisplayName', 'GR2');

xlabel('Motor Speed (rpm)');
ylabel('Motor Torque (Nm)');
zlabel('Motor Efficiency (%)');
title('Motor Efficiency Map with UDDS Operating Points (2-Speed)');
grid on;
view(3);
legend('show', 'Location', 'northeast');

%% ================= EFFICIENCY RESULTS =================
fprintf('Motor Energy Consumption(%%): %.2f\n', out.Motor_Energy.Data(end));
fprintf('\n--- GR1 ---\n');
fprintf('Maximum efficiency (%%): %.2f\n', max(M_Eff(idx1)));
fprintf('Average efficiency (%%): %.2f\n', mean(M_Eff(idx1), 'omitnan'));
fprintf('Lowest efficiency (%%):  %.2f\n', min(M_Eff(idx1)));

fprintf('\n--- GR2 ---\n');
fprintf('Maximum efficiency (%%): %.2f\n', max(M_Eff(idx2)));
fprintf('Average efficiency (%%): %.2f\n', mean(M_Eff(idx2), 'omitnan'));
fprintf('Lowest efficiency (%%):  %.2f\n', min(M_Eff(idx2)));

fprintf('\n--- Overall ---\n');
fprintf('Average efficiency (%%): %.2f\n', mean(M_Eff(idx1 | idx2), 'omitnan'));

