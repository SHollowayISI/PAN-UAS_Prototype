
close all;

data_raw = parsed_data(:,1,1,1);

data_diff = diff(data_raw);
med_diff = median(abs(data_diff));

up_ind = find(data_diff > 10*med_diff);
down_ind = find(data_diff < -10*med_diff);

figure;
plot(data_raw);










