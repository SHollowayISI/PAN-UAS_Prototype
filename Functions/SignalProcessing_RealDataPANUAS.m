function [cube] = SignalProcessing_PANUAS(scenario)
%SIGNALPROCESSING_PANUAS Performs signal processing for PANUAS
%   Takes scenario struct as input, retuns scenario.cube struct containing
%   processed Range-Doppler cube

%% Unpack Variables

radarsetup = scenario.radarsetup;
simsetup = scenario.simsetup;

%% Define Constants

c = physconst('LightSpeed');
lambda = c/radarsetup.f_c;

%% Apply Calibration

% Load calibration cube
cal_cube = load(simsetup.cal_file);
cal_cube = cal_cube.cal;

% Apply calibration
cal_sig = scenario.rx_sig./cal_cube;

%% Perform Range FFT

% Calculate FFT Size
N_r = 2^ceil(log2(size(scenario.rx_sig,1)));

% Apply windowing
expression = '(size(scenario.rx_sig,1)).*cal_sig;';
expression = [ radarsetup.r_win, expression];
cube.range_cube = eval(expression);

% FFT across fast time dimension
cube.range_cube = fft(scenario.rx_sig, N_r, 1);

% Remove negative complex frequencies
cube.range_cube = cube.range_cube(1:ceil(end/2),:,:,:);

%% Perform Doppler FFT

% Calculate FFT size
N_d = 2^ceil(log2(size(cube.range_cube,2)));

% Apply windowing
expression = '(size(cube.range_cube,2))).*cube.range_cube;';
expression = ['transpose(', radarsetup.d_win, expression];
cube.rd_cube = eval(expression);

% Clear range cube
if simsetup.clear_cube
    cube.range_cube = [];
end

% FFT across slow time dimension
cube.rd_cube = fftshift(fft(cube.rd_cube, N_d, 2), 2);

% Wrap max negative frequency and positive frequency
cube.rd_cube(:,(end+1),:,:) = cube.rd_cube(:,1,:,:);

%% Rearrange MIMO Cube

% Layout arrays
%TODO: MOVE TO INPUT
tx_layout = [4, 1; ...
             3, 2];
rx_layout = [16, 15, 14, 13; ...
             12, 11, 10,  9; ...
              8,  7,  6,  5; ...
              4,  3,  2,  1];

[tx_z, tx_y] = size(tx_layout);
[rx_z, rx_y] = size(rx_layout);

% Loop through MIMO cube dimensions, aligning correctly along physical layout
for tz = 1:tx_z
    for ty = 1:tx_y
        for rz = 1:rx_z
            for ry = 1:rx_y
                
                z_ind = rz + rx_z*(tz-1);
                y_ind = ry + rx_y*(ty-1);
                
                tx_ind = tx_layout(tz,ty);
                rx_ind = rx_layout(rz,ry);
                
                cube.mimo_cube(:,:,y_ind,z_ind) = cube.rd_cube(:,:,tx_ind,rx_ind);
                
            end
        end
    end
end

% Clear doppler cube
if simsetup.clear_cube
    cube.rd_cube = [];
end

%% Perform Angle FFTs

% Calculate FFT size 
switch radarsetup.angle_method
    case 'fit'
        N_az = 2^ceil(log2(size(cube.mimo_cube, 3)));
        N_el = 2^ceil(log2(size(cube.mimo_cube, 4)));
    case 'set'
        N_az = radarsetup.n_az;
        N_el = radarsetup.n_el;
end

% Apply azimuth windowing
expression = '(size(cube.mimo_cube,3)), [2 3 1]).*cube.mimo_cube;';
expression = ['permute(', radarsetup.az_win, expression];
cube.angle_cube = eval(expression);

% Apply elevation windowing
expression = '(size(cube.angle_cube,4)), [2 3 4 1]).*cube.angle_cube;';
expression = ['permute(', radarsetup.el_win, expression];
cube.angle_cube = eval(expression);

% Clear MIMO cube
if simsetup.clear_cube
    cube.mimo_cube = [];
end

% FFT across angle dimensions
cube.angle_cube = fftshift(fft(cube.angle_cube, N_az, 3), 3);
cube.angle_cube = fftshift(fft(cube.angle_cube, N_el, 4), 4);

% Wrap max negative frequency and positive frequency
cube.angle_cube(:,:,(end+1),:) = cube.angle_cube(:,:,1,:);
cube.angle_cube(:,:,:,(end+1)) = cube.angle_cube(:,:,:,1);

%% Calculate Power Cube

% Take square magnitude of radar cube
cube.pow_cube = abs(cube.angle_cube).^2;

% Clear angle cube
if simsetup.clear_cube
    cube.angle_cube = [];
end

%% Derive Axes

% Derive Range axis
cube.range_res = ((size(scenario.rx_sig,1) + radarsetup.drop_s)/N_r)*(c/(2*radarsetup.bw));
cube.range_axis = ((1:(N_r/2))-1)*cube.range_res;

% Derive Doppler axis
cube.vel_res = lambda/(2*radarsetup.pri*radarsetup.n_p*radarsetup.n_tx_y*radarsetup.n_tx_z);
cube.vel_axis = ((-N_d/2):(N_d/2))*cube.vel_res;

% Derive Azimuth axis
cube.azimuth_axis = asind(((-N_az/2):(N_az/2))*(2/N_az));
cube.azimuth_res = min(abs(diff(cube.azimuth_axis)));


% Derive Elevation axis
cube.elevation_axis = asind(((-N_el/2):(N_el/2))*(2/N_el));
cube.elevation_res = min(abs(diff(cube.elevation_axis)));


end