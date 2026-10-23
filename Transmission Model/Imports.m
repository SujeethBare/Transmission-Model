clc; clear; close all;

Drive = readmatrix('UDDS.csv');

Mv = 1630.665;
Md = 80;
GVM = Mv + Md;
g = 9.81;
GVW = GVM*g;

Crf = 0.015;
Fa = 3.8056;
rho = 1.225;
Cd = 0.28;
Rw = 0.2032;

GR = 7.96;
Teff = 0.89;


%Processing%
Meff = readmatrix("Nissan Leaf Motor Controller Efficiency.csv");
Meff_Torque = Meff(:,17);
Meff_Speed = Meff(:,1);
Meff_eff = Meff(:,2:16);

MDP = readmatrix("Motor Efficiency Data Less Points.csv");
MDP_Torque = MDP(:,2);
MDP_Speed = MDP(:,1);
MDP_eff = MDP(:,3);

Motor = readmatrix('Nissan Leaf MC.csv');
Motor_Speed = Motor(:,1);
Motor_Ptorque = Motor(:,2);
Motor_Ctorque = Motor(:,3);

out = sim('Powertrain');

Op_Speed = out.Motor_Speed.Data;
Op_Torque = out.Motor_Torque.Data;

figure; hold on; box on;
for i=1:length(GR_set)
    plot(Motor_Speed, Motor_Ptorque, 'r');
    plot(Motor_Speed, Motor_Ctorque, 'g');
    text(1000, 280, 'Motor Peak Torque');
    text(1000, 155, 'Motor Continuous Torque');
    scatter(array_motor_speed(:,i), array_motor_torque(:,i), 'b');
    scatter(MDP_Speed, MDP_Torque, 10, 'r', 'filled');
    text(MDP_Speed, MDP_Torque, num2str(MDP_eff*100), 'FontSize', 8);
    xlabel('Motor Speed (rpm)');
    ylabel('Motor Torque (Nm)');
    title('Motor Operating Region - UDDS');
    xlim([0 10000]); ylim([0 300]);
end

figure('Name','Motor efficiency map');
surf(Meff_Speed, Meff_Torque, Meff_eff');
hold on;
scatter3(out.Motor_Speed.Data, out.Motor_Torque.Data, out.Motor_Efficiency.Data, 15, 'r', 'filled');
xlabel('Motor Speed (rpm)');
ylabel('Motor Torque (Nm)');
zlabel('Motor Efficiency (%)');
title('Motor Efficiency Map with UDDS Operating Points');
colorbar;
grid on;
view(45, 30);

M_eff = out.Motor_Efficiency.Data*100;
M_O_avg = mean(M_eff);
disp('Maximum efficiency (%)')
disp(max(M_eff))
disp('Average efficiency (%)')
disp(M_O_avg)
disp('Lowest efficiency (%)')
disp(min(M_eff))