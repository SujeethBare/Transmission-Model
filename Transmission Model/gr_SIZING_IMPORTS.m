%% ===== INPUT DATA =====
drive = readmatrix('UDDS.csv');
Tsim  = drive(end,1);

% Vehicle parameters
Mv   = 1630.665;
Md   = 80;
GVM  = Mv + Md;
g    = 9.81;
GVW  = GVM*g;
Crf  = 0.015;
Fa   = 3.8056;
rho  = 1.225;
Cd   = 0.28;
Rw   = 0.2032;
Teff = 0.89;
GR_set = 1:3;

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

%% ===== SIMULATION LOOP (ALL GEAR RATIOS) =====
array_motor_speed      = [];
array_motor_torque     = [];
array_motor_energy     = [];
array_motor_efficiency = [];

for i = 1:length(GR_set)
    GR  = GR_set(i);
    out = sim('Powertrain.slx', Tsim);
    array_motor_speed(:,i)      = out.Motor_Speed.Data;
    array_motor_torque(:,i)     = out.Motor_Torque.Data;
    array_motor_energy(:,i)     = out.Motor_Energy.Data;
    array_motor_efficiency(:,i) = out.Motor_Efficiency.Data;
end

%% ===== FIGURE 1: MOTOR CHARACTERISTICS (one per GR) =====
for i = 1:length(GR_set)
    figure('Name', ['Motor Characteristics graph - GR ' num2str(GR_set(i))]);
    hold on; box on;

    % Torque envelope
    plot(Motor_Speed, Motor_Ptorque, 'r');
    plot(Motor_Speed, Motor_Ctorque, 'g');
    text(1000, 280, 'Motor Peak Torque');
    text(1000, 155, 'Motor Continuous Torque');

    % UDDS operating points (blue open circles)
    scatter(array_motor_speed(:,i), array_motor_torque(:,i), 'b');

    % Efficiency points with labels
    scatter(MDP_Speed, MDP_Torque, 10, 'r', 'filled');
    text(MDP_Speed, MDP_Torque, num2str(MDP_eff*100), 'FontSize', 8);

    xlabel('Motor Speed (rpm)');
    ylabel('Motor Torque (Nm)');
    title(['Motor Operating Region - UDDS (GR = ' num2str(GR_set(i)) ')']);
    xlim([0 10000]); ylim([0 300]);
end

%% ===== FIGURE 1: OPERATING REGION =====
figure('Name','Motor operating region'); hold on; box on;
plot(Motor_Speed, Motor_Ptorque, 'r', 'LineWidth', 1.5);
plot(Motor_Speed, Motor_Ctorque, 'g', 'LineWidth', 1.5);
text(1000, 280, 'Motor Peak Torque');
text(1000, 155, 'Motor Continuous Torque');

colors = lines(length(GR_set));
for i = 1:length(GR_set)
    scatter(array_motor_speed(:,i), array_motor_torque(:,i), 10, colors(i,:), ...
            'DisplayName', ['GR = ' num2str(GR_set(i))]);
end

scatter(MDP_Speed, MDP_Torque, 10, 'r', 'filled', 'HandleVisibility','off');
text(MDP_Speed, MDP_Torque, num2str(MDP_eff*100), 'FontSize', 8);

xlabel('Motor Speed (rpm)');
ylabel('Motor Torque (Nm)');
title('Motor Operating Region - UDDS');
xlim([0 10000]); ylim([0 300]);
plot(Motor_Speed, Motor_Ptorque, 'r', 'LineWidth', 1.5, 'DisplayName', 'Peak Torque');
plot(Motor_Speed, Motor_Ctorque, 'g', 'LineWidth', 1.5, 'DisplayName', 'Continuous Torque');

%% ===== FIGURE 2: EFFICIENCY MAP (one per GR) =====
for i = 1:length(GR_set)
    figure('Name', ['Motor efficiency map - GR ' num2str(GR_set(i))]);
    surf(Meff_Speed, Meff_Torque, Meff_eff');
    hold on;
    scatter3(array_motor_speed(:,i), array_motor_torque(:,i),array_motor_efficiency(:,i)*100);          % fraction -> %
    xlabel('Motor Speed (rpm)');
    ylabel('Motor Torque (Nm)');
    zlabel('Motor Efficiency (%)');
    title(['Motor Efficiency Map with UDDS Operating Points (GR = ' num2str(GR_set(i)) ')']);
    grid on;
    view(3);
end

%% ===== EFFICIENCY RESULTS =====
for i = 1:length(GR_set)
    M_eff = array_motor_efficiency(:,i)*100;
    fprintf('\n--- GR = %d ---\n', GR_set(i));
    fprintf('Maximum efficiency (%%): %.2f\n', max(M_eff));
    fprintf('Average efficiency (%%): %.2f\n', mean(M_eff, 'omitnan'));
    fprintf('Lowest efficiency (%%):  %.2f\n', min(M_eff));
end