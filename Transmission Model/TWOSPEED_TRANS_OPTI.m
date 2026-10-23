%Here we perform a Linear Search Algorithm for the best GR1 and GR2 to get
%best eff at the same time least energy consumption
clear; clc;
Drive = readmatrix('UDDS.csv');
Mv = 1650.665;
Md = 80;
GVM = Mv + Md;
g = 9.81;
GVW = GVM*g;
Crf = 0.015;
Fa = 3.8056;
rho = 1.225;
Cd = 0.28;
Rw = 0.2032;
v_shift= 25; %shifting at velocity kmph
Teff = 0.89;

G1max= 11.075;
G2max= 7.96;  %two speed
G1min= 6.06;
G2min= 5.41;
G1=linspace(G1max,G1min,3); %here just 3 set of no's are used: more the better
G2=linspace(G2max,G2min,3);
[G1_range,G2_range]=ndgrid(G1,G2);

Mot_P_Torque=200;%Nm
Mot_P_Speed=10390;%rpm
Mot_Energy= [];
Mot_Eff= {};
Mot_Speed= [];
Mot_Torque= [];
Mot_Avg_Energy= {};
itera= 1; %iterations
k=1;

%%THESE ARE GOING TO BE OUR FINAL VALUES: INITIALISED HERE WITH
%%INITIAL/DUMMY VALUES--> IT WILL BE UPDATED LATER INSIDE THE LOOP
Gear_1_Select= 0;  %Selected GR just for the loop
Gear_2_Select= 0;  %Selected GR just for the loop
Mot_Energ_SelecVal= inf; %inf is just for the loop..will get updated at end of loop
Mot_Torque_SelecVal= inf;   %inf is just for the loop..will get updated at end of loop
Mot_TorqueG1_SelecVal= inf; 
Mot_TorqueG2_SelecVal= inf; 
Mot_Speed_SelecVal= inf; 
Mot_AvgEff_SelecVal= 0;
Mot_Eff_SelecVal= 0;
itera_SelecVal= 1;
irange= []; %range of iteration values
Mot_Energy_e= [];
Mot_Eff_e= [];
io= 0;

Meff = readmatrix("Nissan Leaf Motor Controller Efficiency.csv");
Meff_Torque = Meff(:,17);
Meff_Speed = Meff(:,1);
Meff_eff = Meff(:,2:16);
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
for i=1:size(G1_range,1)
for j=1:size(G1_range,2)
        G1=G1_range(i,j);
        G2=G2_range(i,j);
        out=sim("Powertrain_2GR.slx");
        Mot_Avg_Eff(i,j)= mean(out.Motor_Efficiency.Data);
        Mot_Energy(i,j)= out.Motor_Energy.Data(end); %array
        Mot_Energy_Matrix(i,j)= out.Motor_Energy.Data(end);  %matrix form
        Mot_Torque(:,itera)= out.Motor_Torque.Data;
        Mot_Speed(:,itera)= out.Motor_Speed.Data;
        M_Speed = out.Motor_Speed.Data;
        T_GR1   = out.Motor_Torq_GR1.Data;
        T_GR2   = out.Motor_Torq_GR2.Data;
        M_Eff   = out.Motor_Efficiency.Data*100;
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
        title(sprintf('Motor Operating Region - G1 = %.2f, G2 = %.2f', G1, G2));
        xlim([0 10000]); ylim([0 300]);
        legend('show', 'Location', 'northeast');
        legend('show', 'Location', 'northeast');
       % saveas(gcf, sprintf('Operating_Points_G1_%.2f_G2_%.2f.png', G1, G2));
        %% ============= FIGURE 2: MOTOR EFFICIENCY MAP =============
        figure('Name','Motor efficiency map'); hold on;
        surf(Meff_Speed, Meff_Torque, Meff_eff', 'HandleVisibility','off');
        scatter3(M_Speed(idx1), T_GR1(idx1), M_Eff(idx1), 15, 'b', 'DisplayName', 'GR1');
        scatter3(M_Speed(idx2), T_GR2(idx2), M_Eff(idx2), 15, 'm', 'DisplayName', 'GR2');
        xlabel('Motor Speed (rpm)');
        ylabel('Motor Torque (Nm)');
        zlabel('Motor Efficiency (%)');
        title(sprintf('Motor Efficiency Map - G1 = %.2f, G2 = %.2f', G1, G2));
        grid on;
        view(3);
        legend('show', 'Location', 'northeast');
        legend('show', 'Location', 'northeast');
        %saveas(gcf, sprintf('Efficiency_Map_G1_%.2f_G2_%.2f.png', G1, G2));

        %Also make sure that all the operating pts fall under our
        %characteristic graph: so all the pts must be within Peak Torq &
        %Max Speed ---> later get those best eff and best energy vals
        
        if max(out.Motor_Torque.Data)< Mot_P_Torque && max(out.Motor_Speed.Data)<Mot_P_Speed && G1 > G2
            if Mot_Energy_Matrix(i,j)<Mot_Energ_SelecVal &&  Mot_Avg_Eff(i,j)> Mot_AvgEff_SelecVal
            Mot_Energ_SelecVal= Mot_Energy_Matrix(i,j);
            Mot_AvgEff_SelecVal= Mot_Avg_Eff(i,j);
            Gear_1_Select= G1;    
            Gear_2_Select= G2;                          %Ive added another condition saying G1>G2
            row= i;
            column= j;
            %Mot_Torque_SelecVal= Out.Motor_Torque.Data;
            Mot_TorqueG1_SelecVal = out.Motor_Torq_GR1.Data;
            Mot_TorqueG2_SelecVal = out.Motor_Torq_GR2.Data;
            Mot_Speed_SelecVal = out.Motor_Speed.Data;
            Mot_Eff_SelecVal= out.Motor_Efficiency.Data;
            irange(itera_SelecVal)= itera;
            Mot_Energy_e(itera_SelecVal)= Mot_Energy_Matrix(i,j);  
            Mot_Eff_e(itera_SelecVal)= Mot_Avg_Eff(i,j);
            itera_SelecVal= itera_SelecVal+1;
            io= itera;
            end  
        end
             itera=itera+1;
end
end
itera=itera-1; %to get that exact number(initially initlaised as itera=1--> 

%Energy Variation
figure;
surf(G1_range,G2_range,Mot_Energy_Matrix)
xlabel('Gear Ratio 1')
ylabel('Gear Ratio 2')
zlabel('Motor Energy Consumped (Wh)')
title('Motor Energy wrt to Gear Ratios')

%Optimal Motor Energy Consumption based on algorithm
figure('Name','Optimal Motor Energy Chara on Diff GR'); hold on; box on;
scatter(io,Mot_Energ_SelecVal,'r')
xlabel('Converging Interation')
ylabel('Optimal Motor Energy Consumed (Wh)')
title('Convergence Iteration to obtain the Optimal Energy Consumption')

%Optimal Motor Average Efficiency based on algorithm
figure('Name','Optimal Motor Avg Efficiency on Diff GR');
scatter(io,Mot_AvgEff_SelecVal*100,'r')
xlabel('Converging Interation')
ylabel('Optimal Motor Avg Efficiency (%)')
title('Convergence Iteration to obtain the Optimal Motor Efficiency')

%Convergence of the solution for each and every iteration
figure('Name','Motor energy based for each convergence');
scatter(irange,Mot_Energy_e,'o')
xlim([0 max(irange)]); ylim([0 1800])
xlabel('Iterations at which solution converged')
ylabel('Optimal Motor Energy consumed (Wh)')
title('Motor energy based on the algorithm convergence')

%Convergence of the solution for each and every iteration
figure('Name','Motor Average Efficiency based for each convergence');
scatter(irange,Mot_Eff_e*100,'o')
xlim([0 max(irange)]); ylim([0 90])
xlabel('Iterations at which solution converged')
ylabel('Optimal Motor Average Efficiency (%)')
title('Motor Average Efficiency based on the algorithm convergence')

%% ========== FIGURE MOTOR CHARACTERISTICS GRAPH ==========
figure('Name','Optimal Motor Characteristics Graph'); hold on; box on;
% Torque envelope
plot(Motor_Speed, Motor_Ptorque, 'r', 'HandleVisibility','off');
plot(Motor_Speed, Motor_Ctorque, 'g', 'HandleVisibility','off');
text(1000, 280, 'Motor Peak Torque');
text(1000, 155, 'Motor Continuous Torque');

% Operating points
scatter(Mot_Speed_SelecVal, Mot_TorqueG1_SelecVal, 15, 'b', 'DisplayName', 'GR1');
scatter(Mot_Speed_SelecVal, Mot_TorqueG2_SelecVal, 15, 'm', 'DisplayName', 'GR2');

% Efficiency points with labels
scatter(MDP_Speed, MDP_Torque, 10, 'r', 'filled', 'HandleVisibility','off');
text(MDP_Speed, MDP_Torque, num2str(MDP_eff*100), 'FontSize', 8);

xlabel('Motor Speed (rpm)');
ylabel('Motor Torque (Nm)');
xlim([0 10000]); ylim([0 300]);
legend('show', 'Location', 'northeast');

%% ============= FIGURE 2: MOTOR EFFICIENCY MAP =============
figure('Name','Optimal Motor Efficiency '); hold on;

surf(Meff_Speed, Meff_Torque, Meff_eff', 'HandleVisibility','off');

scatter3(Mot_Speed_SelecVal, Mot_TorqueG1_SelecVal+Mot_TorqueG2_SelecVal, Mot_Eff_SelecVal*100, 15, 'b', 'DisplayName', 'GR1');

xlabel('Motor Speed (rpm)');
ylabel('Motor Torque (Nm)');
zlabel('Motor Efficiency (%)');
grid on; view(3);
legend('show', 'Location', 'northeast');

%Logic is right somewhere down the line there is an ssue:spent 3 days. no time to die