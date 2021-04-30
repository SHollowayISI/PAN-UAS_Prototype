function [dist] = MahanalobisDistance( ...
    detect, det_ind, track, EKF, sigma_z, RDtau)
%MAHANALOBISDISTANCE Mahanalobis Distance calculation
%   Calculates "nearest neighbor" distance for tracking
%   Inputs:
%       detect  :   Struct element of detect_list
%       det_ind :   Index of detection under review
%       track   :   Struct element of track_list
%       EKF     :   T/F Extended Kalman Filter
%       sigma_z :   Measurement covariance
%       Tm      :   Time step since last update
%       RDtau   :   Range-Doppler coupling factor for LFM waveform 
%                       (= f_c * t_ramp / bandwidth)

%% Unpack variales

% Unpack measurement
if EKF
    Z = [detect.range(det_ind); ...
            detect.az(det_ind); ...
            detect.el(det_ind); ...
            detect.vel(det_ind);];
else
    Z = detect.cart(:,det_ind);
end

% Unpack kinematic prediction and uncertainty
X_pre = track.kin_pre;
P_pre = track.unc_pre;

%%%%% DEBUG %%%%%%%%%
X_cart = [X_pre(1); X_pre(3); X_pre(5)];
dist = sqrt(sum((X_cart - detect.cart(:,det_ind)).^2));
return;

%% Calculate Matrices

% Calculate measurement matrix
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

% Calculate process covariance
if EKF
    R = (sigma_z.^2) .* eye(4);
else
    R = (sigma_z(1:3).^2) .* eye(3);
end
% Calculate measurement covariance residual
S = H * P_pre * H' + R;

%% Calculate Mahanalobis Distance

% Complete calculation
dist = Z_res' * (S \ Z_res);


end

