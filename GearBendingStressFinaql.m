
% Elias A Reyes
% Gear stress calculator 
% 11/2025

% This caluculator takes several dimensional and power constraints and
% rapidly calculates an appropriate face width for a gear considering the
% material selected for this application.


%  GEARBOX DESIGN PARAMETERS
% Input power and speed
Hp_in  = 0.1;          % horsepower
rpm_in = 1500;         % rpm

% Gear geometry (diameters in inches)
Dp_A = 1;            % Stage A pinion
Dg_A = 3.5;          % Stage A gear

Dp_B = 1;            % Stage B pinion
Dg_B = 3.5;          % Stage B gear


% Material properties
Mat  = 'PC (polycarbonate)';    % material name
S_ut = 8.3977;                  % tensile strength (ksi)
C_l  = 1.0;
C_g  = 1.0;
C_s  = 1;
K_r  = 0.814;
K_t  = 1.0;
K_ms = 1.4;

% Stage A (input side) parameters
P_A = 10;                    % diametral pitch (teeth per inch)
J_fac_pinion_a = 0.2;        % geometry factor J
J_fac_gear_a = 0.28;
K_o_a = 1.25;
K_m_a = 1.6;
n_safe = 2.5;                % target safety factor

%Stage B (output) parameters 
P_B =  10;
J_fac_pinion_B = 0.2;        % geometry factor J
J_fac_gear_B = 0.28;

fprintf('\nInput:\nHP = %.1f\nRPM = %.0f\n', Hp_in, rpm_in);

% Tangential force and torque calcs
W_pfs = Hp_in * 550; 
Omega_shaft_a = rpm_in * (2*pi/60);

F_tan_a = W_pfs / ((Dp_A/24)*Omega_shaft_a); 
Trq_shaft_b = F_tan_a * (Dg_A/2) / 12; % 12 to get ft lb
rpm_shaft_b = (Hp_in * 5252) / Trq_shaft_b;
F_tan_b = Trq_shaft_b / ((Dp_B/2)/12);

Trq_shaft_c = F_tan_b * (Dg_B/2)/12;% 12 to get ft lb
rpm_shaft_c = (Hp_in * 5252) / Trq_shaft_c;

fprintf('\nTangential Forces:\n');
fprintf('Ft Stage A = %.2f lbf\n', F_tan_a);
fprintf('Ft Stage B = %.2f lbf\n', F_tan_b);

fprintf('\nRadial Forces:\n');
fprintf('Fr Stage A = %.2f lbf\n', F_tan_a * tan(deg2rad(20)));
fprintf('Fr Stage B = %.2f lbf\n', F_tan_b* tan(deg2rad(20)));

% Endurance limit
S_prime_n = 0.5 * S_ut;
S_n = S_prime_n * C_l * C_s * C_g * K_r * K_t * K_ms;
S_n_psi = S_n * 1000;

fprintf('\nMaterial: %s\nEndurance Limit = %.2f ksi\n', Mat, S_n);

% Bending stress
N_p_a = P_A * Dp_A;
N_g_a = P_A * Dg_A;
V_a = (pi * Dp_A * rpm_in) / 12;
K_v_a = (50 + sqrt(V_a)) / 50;
fprintf('\n--- STAGE A 4.5 : 1 (input) ---:\n');
fprintf('P = %.0f (T/in) Np = %.2fT   Ng = %.2fT \n',P_A, N_p_a, N_g_a);
fprintf('Pitch line velocity V = %.2f ft/min\n', V_a);
fprintf('Kv = %.2f\n', K_v_a);

% Sigma pinion A stage

Sigma_p_a = (F_tan_a * P_A * K_v_a * K_o_a * K_m_a) / J_fac_pinion_a;
% Solve for face width
face_b = (Sigma_p_a * n_safe) / S_n_psi;
Lower_bound_a = 9/P_A;
Upper_bound_a = 14/P_A;

%check gear bending stress with this diameter

Sigma_g_a = (F_tan_a * P_A * K_v_a * K_o_a * K_m_a) / J_fac_gear_a;
allowable = S_n_psi /n_safe;
fprintf('Guideline: %.2f in < %.2f in < %.2f in ',Lower_bound_a, face_b ,Upper_bound_a);
fprintf('\nRequired Face Width Pinion A = %.2f in\n\n', face_b);
fprintf('Stage A Gear stress test\n');
fprintf('Bending Stress---> %.2f psi < %.2f psi <---- allowable',Sigma_g_a , allowable)
%----------------------------------------------------------------------------------------

% Bending stress STAGE B
N_p_B = P_B * Dp_B;
N_g_B = P_B * Dg_B;
V_B = (pi * Dp_B *  rpm_shaft_b ) / 12;
K_v_B = (50 + sqrt(V_B)) / 50;
fprintf('\n\n')

fprintf('\n--- STAGE B 4.5 : 1 (output) ---:\n');
fprintf('P= %.2f (T/in) Np = %.0f   Ng = %.0f\n',P_B , N_p_B, N_g_B);
fprintf('Pitch-line velocity V = %.2f ft/min\n', V_B);
fprintf('Kv = %.2f\n', K_v_B);
% Sigma pinion B stage
Sigma_p_B = (F_tan_b * P_B * K_v_B * K_o_a * K_m_a) / J_fac_pinion_B;
% Solve for face width
face_b_2 = (Sigma_p_B * n_safe) / S_n_psi;
Lower_bound_B = 9/P_B;
Upper_bound_B = 14/P_B;
%check gear bending stress with this diameter
Sigma_g_B = (F_tan_b * P_B * K_v_B * K_o_a * K_m_a) / (face_b_2 * J_fac_gear_B);
Sigma_p_B = Sigma_p_B /face_b_2 ;
fprintf('Pinion B Bending Stress %.02f psi \n', Sigma_p_B)
allowable = S_n_psi /n_safe;
fprintf('Guideline: %.2f in < %.2f in < %.2f in ',Lower_bound_B, face_b_2 ,Upper_bound_B);
fprintf('\nRequired Face Width Pinion B = %.3f in\n\n', face_b_2);
fprintf('Stage B Gear stress test\n');
fprintf('Bending Stress---> %.2f psi < %.2f psi <---- Allowable \n\n',Sigma_g_B , allowable)

fprintf('--- SHAFT RPM --- \n');

fprintf ('Input Shaft: %.2f rpm\n ', rpm_in);

fprintf ('Countershaft: %.02f rpm \n',rpm_shaft_b);
fprintf ('Output Shaft: %.2f rpm ',rpm_shaft_c);