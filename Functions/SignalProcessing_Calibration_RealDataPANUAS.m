function [cube] = SignalProcessing_Calibration_RealDataPANUAS(scenario)
%SIGNALPROCESSING_CALIBRATION_REALDATAPANUAS Performs signal processing for PANUAS
%   Takes scenario struct as input, retuns scenario.cube struct containing
%   processed Range-Doppler cube

%% Unpack Variables

radarsetup = scenario.radarsetup;
simsetup = scenario.simsetup;

%% Define Constants

c = physconst('LightSpeed');
lambda = c/radarsetup.f_c;

%% Perform Range FFT

% Calculate FFT Size
N_r = 2^ceil(log2(size(scenario.parsed_data,1)));

% Apply windowing
expression = '(size(scenario.parsed_data,1)).*scenario.parsed_data;';
expression = [ radarsetup.r_win, expression];
cube.range_cube = eval(expression);

% FFT across fast time dimension
cube.range_cube = fft(scenario.parsed_data, N_r, 1);

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

%% Calculate Power Cube

% Take square magnitude of radar cube
cube.pow_cube = abs(cube.rd_cube).^2;

%% Derive Axes

% Derive Range axis
cube.range_res = ((size(scenario.parsed_data,1) + radarsetup.drop_s)/N_r)*(c/(2*radarsetup.bw));
cube.range_axis = ((1:(N_r/2))-1)*cube.range_res;

% Derive Doppler axis
cube.vel_res = lambda/(2*radarsetup.t_ch*radarsetup.n_p*radarsetup.n_tx_y*radarsetup.n_tx_z);
cube.vel_axis = ((-N_d/2):(N_d/2))*cube.vel_res;


end