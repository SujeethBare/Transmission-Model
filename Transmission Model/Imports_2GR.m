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

G1max= 11.075;
G2max= 7.96;  %two speed
G1min= 6.06;
G2min= 5.41;
G1_range=[G1min,(G1max+G1min)/2,G1max];
G2_range=[G2min,(G2max+G2min)/2,G2max];
v_shift= 25; %shifting at velocity kmph
Teff = 0.89;

%Processing%
Meff = readmatrix("Nissan Leaf Motor Controller Efficiency.csv");
Meff_Torque = Meff(:,17);
Meff_Speed = Meff(:,1);
Meff_eff = Meff(:,2:16);

