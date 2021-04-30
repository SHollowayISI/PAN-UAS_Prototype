function [kin_est, kin_pre, unc_pre] = ...
    KalmanFilter_Step(meas, X_pre, P_pre, Tm, sigma_v, sigma_z, EKF, RDtau)
%KALMANFILTER_STEP Performs single step of Kalman filter
%   Performs Kalman filter predictor-corrector algorithm.
%   Inputs:
%       meas    :   Struct containing radar measurements
%       X_pre   :   Kinematic prediction matrix
%       P_pre   :   Uncertainty prediction matrix
%       Tm      :   Time step since last update
%       sigma_v :   Process uncertainty
%       sigma_z :   Measurement uncertainty
%       EKF     :   T/F Extended Kalman Filter
%       RDtau   :   Range-Doppler coupling factor for LFM waveform 
%                       (= f_c * t_ramp / bandwidth)

%% Unpack Variables

% Unpack measurement
if EKF
    Z = [meas.range; meas.az; meas.el; meas.vel];
else
    Z = meas.cart;
end

%% Calculate Matrices

% Process covariance matrix
if EKF
    R = (sigma_z.^2) .* eye(4);
else
    R = (sigma_z(1:3).^2) .* eye(3);
end

% Process covariance matrix (DWNA assumption)
Q_1d = [(Tm^4)/4, (Tm^3)/2; ...
        (Tm^3)/2, (Tm^2)];

% Process covariance matrix (CWNA assumption)
% Q_1d = [(Tm^3)/3, (Tm^2)/2; ...
%         (Tm^2)/2, (Tm^1)];
    
Q = [Q_1d*(sigma_v(1)^2), zeros(2), zeros(2); ...
    zeros(2), Q_1d*(sigma_v(2)^2), zeros(2); ...
    zeros(2), zeros(2), Q_1d*(sigma_v(3)^2)];

% Kinematic process matrix
F_1d = [1, Tm; 0, 1];
F = [F_1d, zeros(2), zeros(2); ...
    zeros(2), F_1d, zeros(2); ...
    zeros(2), zeros(2), F_1d];

% Initialize uncertainty if this is first step
if isempty(P_pre)
    if EKF
        P_lin = zeros(1, 6);
        P_lin(1) = sqrt((sigma_z(1)^2) * (cos(Z(2))^2) * (cos(Z(3))^2) + ...
            (sigma_z(2)^2) * (Z(1)^2) * (sin(Z(2))^2) * (cos(Z(3))^2) + ...
            (sigma_z(3)^2) * (Z(1)^2) * (cos(Z(2))^2) * (sin(Z(3))^2));
        P_lin(3) = sqrt((sigma_z(1)^2) * (sin(Z(2))^2) * (cos(Z(3))^2) + ...
            (sigma_z(2)^2) * (Z(1)^2) * (cos(Z(2))^2) * (cos(Z(3))^2) + ...
            (sigma_z(3)^2) * (Z(1)^2) * (sin(Z(2))^2) * (sin(Z(3))^2));
        P_lin(5) = sqrt((sigma_z(1)^2) * (sin(Z(3))^2) + ...
            (sigma_z(3)^2) * (Z(1)^2) * (cos(Z(3))^2));
        
        P_lin(2) = (sigma_z(4) / (cos(Z(2))*cos(Z(3))))^2;
        P_lin(4) = (sigma_z(4) / (sin(Z(2))*cos(Z(3))))^2;
        P_lin(6) = (sigma_z(4) / sin(Z(3)))^2;
        
        P_pre = diag(P_lin);
    else
        P_pre = Q;
    end
end

% Measurement matrix and measurement residual
if EKF

    % Measurement residual
    h_r = sqrt(X_pre(1)^2 + X_pre(3)^2 + X_pre(5)^2);
    h_rh = sqrt(X_pre(1)^2 + X_pre(3)^2);
    h_b = atan(X_pre(3) / X_pre(1));
    h_e = atan(X_pre(5) / sqrt(X_pre(1)^2 + X_pre(3)^2));
    h_d = (X_pre(1)*X_pre(2) + X_pre(3)*X_pre(4) + X_pre(5)*X_pre(6)) / h_r;
    
    % Range doppler coupling adjustment
    h_rd = h_r + RDtau * h_d;
    
    % Measurement residual matrix
    h = [h_rd; h_b; h_e; h_d];
    Z_res = Z - h;
    
    % Measurement matrix
    H_r = [X_pre(1), 0, X_pre(3), 0, X_pre(5), 0]/h_r;
    H_b = [-X_pre(3), 0, X_pre(1), 0, 0, 0]/(h_rh^2);
    H_e = [-X_pre(1)*X_pre(5), 0, -X_pre(3)*X_pre(5), 0, h_rh^2, 0] / ...
        (h_r * h_r * h_rh);
    H_d(1) = ((X_pre(3)^2 + X_pre(5)^2)*X_pre(2) - (X_pre(3)*X_pre(4) + X_pre(5)*X_pre(6))*X_pre(1)) / ...
        (h_r^3);
    H_d(2) = X_pre(1)/h_r;
    H_d(3) = ((X_pre(1)^2 + X_pre(5)^2)*X_pre(4) - (X_pre(1)*X_pre(2) + X_pre(5)*X_pre(6))*X_pre(3)) / ...
        (h_r^3);
    H_d(4) = X_pre(3)/h_r;
    H_d(5) = (h_rh*h_rh*X_pre(6) - (X_pre(1)*X_pre(2) + X_pre(3)*X_pre(4))*X_pre(5)) / ...
        (h_r^3);
    H_d(6) = X_pre(5)/h_r;
    
    % Range doppler coupling adjustment
    H_rd = H_r + RDtau * H_d;
    H = [H_rd; H_b; H_e; H_d];
    
else
    
    % Measurement matrix
    H = [1, 0, 0, 0, 0, 0; ...
         0, 0, 1, 0, 0, 0; ...
         0, 0, 0, 0, 1, 0];
    
    % Measurement residual
    Z_res = Z - (H * X_pre);
end

%% Estimation Step

% Measurement residual covariance
S = H * (P_pre * H') + R;

% Kalman matrix
K = P_pre * H' / S;

% Estimated kinematic vector
kin_est = X_pre + K * Z_res;

% Estimated kinematic covariance
unc_est = P_pre - K * (H * P_pre);

%% Prediction Step

% Predicted kinematic vector
kin_pre = F * kin_est;

% Predicted kinematic covariance
unc_pre = F * (unc_est * F') + Q;

end

