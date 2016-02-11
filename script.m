clear;
clc;
close all;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% info = audiodevinfo
% Fs = 48000;
% recordObj = audiorecorder(Fs, 8, 1, 0)
% disp('Start speaking.');
% recordblocking(recordObj, 10);
% disp('End of Recording.');
% play(recordObj);
% recorded_signal_t = getaudiodata(recordObj);
% t = linspace(0, 10, length(recorded_signal_t));
% figure('Name','Recorded Signal Time domain');
% plot(t, recorded_signal_t);
fileName = 'test.wav';
% audiowrite(fileName, recorded_signal_t, Fs);
[recorded_signal_t, Fs] = audioread(fileName);
Fs
% sound(recorded_signal_t, Fs);
t = linspace(0, 10, length(recorded_signal_t));
% figure('Name','Recorded Signal in Time domain');
% plot(t, real(recorded_signal_t));
% title('Recorded Signal in Time domain')
% xlabel('time')
% ylabel('amplitude')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
recorded_signal_f = fftshift(fft(recorded_signal_t));
f = linspace(-Fs/2, Fs/2, length(recorded_signal_f));
f_filtered = f;
f_filtered((f_filtered > -4000) & (f_filtered < 4000)) = 1;
f_filtered((f_filtered > 4000) | (f_filtered < -4000)) = 0;
% figure('Name','Recorded Signal in Frequency domain');
% stem(f, abs(recorded_signal_f));
% title('Recorded Signal in Frequency domain')
% xlabel('frequency')
% ylabel('amplitude')
recorded_signal_f_filtered = f_filtered' .* recorded_signal_f;
% figure('Name','Filtered Signal in Frequency domain');
% stem(f, abs(recorded_signal_f_filtered));
% title('Filtered Signal in Frequency domain')
% xlabel('frequency')
% ylabel('amplitude')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
recorded_signal_t_filtered = ifft(recorded_signal_f_filtered);
% figure('Name','Filtered Signal in Time domain');
% plot(t, real(recorded_signal_t_filtered));
% title('Filtered Signal in Time domain')
% xlabel('time')
% ylabel('amplitude')
% sound(abs(recorded_signal_t_filtered), Fs);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mse  = immse(real(recorded_signal_t_filtered), recorded_signal_t)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 5 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Vc = 2 * max(real(recorded_signal_t_filtered));
Fc = 1 * 10^5;
Wc = 2 * pi * Fc;
Fs_new = 3 * Fc;
[p,q] = rat(Fs_new/Fs, 0.0001);
signal_t_resampled = resample(recorded_signal_t_filtered, p, q);
t_new = linspace(0, 10, length(signal_t_resampled));
carrier_cos_sc = cos(Wc .* t_new);
carrier_cos_tc = Vc + cos(Wc .* t_new);
modulated_signal_t_sc2 = (signal_t_resampled) .* carrier_cos_sc';
modulated_signal_t_tc2 = (signal_t_resampled) .* carrier_cos_tc';
[p,q] = rat(Fs/Fs_new, 0.0001);
modulated_signal_t_sc = Fc * resample(modulated_signal_t_sc2, p, q);
modulated_signal_t_tc = 10 * resample(modulated_signal_t_tc2, p, q);
% figure('Name','Modulated DSBSC in Time domain');
% plot(t, real(modulated_signal_t_sc));
% title('Modulated DSBSC in Time domain')
% xlabel('time')
% ylabel('amplitude')
% sound(abs(recorded_signal_t_filtered), Fs);
% figure('Name','Modulated DSBTC in Time domain');
% plot(t, real(modulated_signal_t_tc));
% title('Modulated DSBTC in Time domain')
% xlabel('time')
% ylabel('amplitude')
% sound(abs(recorded_signal_t_filtered), Fs);
modulated_signal_f_sc2 = 1/Fs_new * fftshift((fft(modulated_signal_t_sc2)));
modulated_signal_f_tc2 = 1/Fs_new * fftshift((fft(modulated_signal_t_tc2)));
modulated_signal_f_sc = resample(modulated_signal_f_sc2, p, q);
modulated_signal_f_tc = resample(modulated_signal_f_tc2, p, q);
% f_new = linspace(-Fs_new/2, Fs_new/2, length(modulated_signal_f_sc));
% figure('Name','Modulated DSBSC in Frequency domain');
% stem(f, abs(modulated_signal_f_sc));
% title('Modulated DSBSC in Frequency domain')
% xlabel('frequency')
% ylabel('amplitude')
% figure('Name','Modulated DSBTC in Frequency domain');
% stem(f, abs(modulated_signal_f_tc));
% title('Modulated DSBTC in Frequency domain')
% xlabel('frequency')
% ylabel('amplitude')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 5 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Old Way
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 5 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Fc = 1 * 10^6;
% % Fs_new = 3 * Fc;
% % 
% % modulated_signal_t_sc = modulate(recorded_signal_t_filtered, Fc, Fs_new, 'amdsb-sc');
% % modulated_signal_f_sc = 1/Fs_new * (fftshift(fft(modulated_signal_t_sc)));
% % f_new = linspace(-Fs_new/2 , Fs_new/2 , length(modulated_signal_f_sc));
% % % figure('Name','Modulated DSBSC in Frequency domain');
% % % stem(f_new, abs(modulated_signal_f_sc));
% % 
% % Vc = 2 * max(real(recorded_signal_t_filtered));
% % modulated_signal_t_tc = ammod(real(recorded_signal_t_filtered), Fc, Fs_new, 0, Vc);
% % modulated_signal_f_tc = 1/Fs_new*(fftshift(fft(modulated_signal_t_tc)));
% % % figure('Name','Modulated DSBTC in Frequency domain');
% % % stem(f_new, abs(modulated_signal_f_tc));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 5 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 6 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
envelope_t_sc = (hilbert(modulated_signal_t_sc));
envelope_f_sc = fftshift(fft(abs(envelope_t_sc)));
envelope_t_tc = (hilbert(modulated_signal_t_tc));
envelope_f_tc = fftshift(fft(abs(envelope_t_tc)));
% figure('Name','Received DSBSC in Time domain');
% plot(t, real(envelope_t_sc));
% title('Received DSBSC in Time domain')
% xlabel('time')
% ylabel('amplitude')
% sound(abs(recorded_signal_t_filtered), Fs);
% figure('Name','Received DSBTC in Time domain');
% plot(t, real(envelope_t_tc));
% title('Received DSBTC in Time domain')
% xlabel('time')
% ylabel('amplitude')
% sound(abs(recorded_signal_t_filtered), Fs);
% figure('Name','Received DSBSC in Frequency domain');
% stem(f, abs(envelope_f_sc));
% title('Received DSBSC in Frequency domainn')
% xlabel('frequency')
% ylabel('amplitude')
% figure('Name','Received DSBTC in Frequency domain');
% stem(f, abs(envelope_f_tc));
% title('Received DSBTC in Frequency domain')
% xlabel('frequency')
% ylabel('amplitude')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 6 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 7 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mse_sc = immse(real(envelope_t_sc), real(modulated_signal_t_sc))
mse_tc = immse(real(envelope_t_tc), real(modulated_signal_t_tc))
% sound(abs(envelope_t_sc), Fs);
% sound(abs(envelope_t_tc), Fs);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 7 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 8 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% modulated_signal_t_tc_0snr = awgn(modulated_signal_t_tc, 0);
% envelope_t_tc_0snr = (hilbert(modulated_signal_t_tc_0snr));
% mse_tc_0snr = immse(real(envelope_t_tc_0snr), real(modulated_signal_t_tc))
% figure('Name','Received DSBTC 0 SNR in Time domain');
% plot(t, real(envelope_t_tc_0snr));
% title('Received DSBTC 0 SNR in Time domain')
% xlabel('time')
% ylabel('amplitude')
% sound(abs(envelope_t_tc_0snr), Fs);
% 
% modulated_signal_t_tc_10snr = awgn(modulated_signal_t_tc, 10);
% envelope_t_tc_10snr = (hilbert(modulated_signal_t_tc_10snr));
% mse_tc_10snr = immse(real(envelope_t_tc_10snr), real(modulated_signal_t_tc))
% figure('Name','Received DSBTC 10 SNR in Time domain');
% plot(t, real(envelope_t_tc_10snr));
% title('Received DSBTC 10 SNR in Time domain')
% xlabel('time')
% ylabel('amplitude')
% sound(abs(envelope_t_tc_10snr), Fs);

% modulated_signal_t_tc_20snr = awgn(modulated_signal_t_tc, 20);
% envelope_t_tc_20snr = (hilbert(modulated_signal_t_tc_20snr));
% mse_tc_20snr = immse(real(envelope_t_tc_20snr), real(modulated_signal_t_tc))
% figure('Name','Received DSBTC 20 SNR in Time domain');
% plot(t, real(envelope_t_tc_20snr));
% title('Received DSBTC 20 SNR in Time domain')
% xlabel('time')
% ylabel('amplitude')
% sound(abs(envelope_t_tc_20snr), Fs);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 8 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 9 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
modulated_signal_t_sc_10snr = awgn(modulated_signal_t_sc, 10);
Wc = 2 * pi * Fc;
coherent_t_sc_10snr = modulated_signal_t_sc_10snr .* (cos(Wc .* t))';
coherent_f_sc_10snr = fft(coherent_t_sc_10snr);
% figure('Name','Received Coherent DSBSC 10 SNR in Time domain');
% plot(t, real(coherent_t_sc_10snr));
% title('Received Coherent DSBSC 10 SNR in Time domain')
% xlabel('time')
% ylabel('amplitude')
% figure('Name','Received Coherent DSBSC 10 SNR in Frequency domain');
% stem(f, abs(coherent_f_sc_10snr));
% title('Received Coherent DSBSC 10 SNR in Frequency domain')
% xlabel('frequency')
% ylabel('amplitude')
f_filtered = f;
f_filtered((f_filtered > 10000) | (f_filtered < -10000)) = 0;
coherent_f_sc_filtered_10snr = 0.01 * (coherent_f_sc_10snr .* f_filtered');
coherent_t_sc_filtered_10snr = ifft(coherent_f_sc_filtered_10snr);
% figure('Name','Received Filtered Coherent DSBSC 10 SNR in Time domain');
% plot(t, real(coherent_t_sc_filtered_10snr));
% title('Received Filtered Coherent DSBSC 10 SNR in Time domain')
% xlabel('time')
% ylabel('amplitude')
% sound(abs(coherent_t_sc_filtered_10snr), Fs);
% figure('Name','Received Filtered Coherent DSBSC 10 SNR in Frequency domain');
% stem(f, abs(coherent_f_sc_filtered_10snr));
% title('Received Filtered Coherent DSBSC 10 SNR in Frequency domain')
% xlabel('frequency')
% ylabel('amplitude')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 9 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 10 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
modulated_signal_t_sc_10snr = awgn(modulated_signal_t_sc, 10);
Fc_2 = 1001000;
Wc_2 = 2 * pi * Fc_2;
coherent_t_sc_10snr = modulated_signal_t_sc_10snr .* (cos(Wc_2 .* t))';
coherent_f_sc_10snr = fft(coherent_t_sc_10snr);
% figure('Name','Received Coherent DSBSC 10 SNR in Time domain');
% plot(t, real(coherent_t_sc_10snr));
% figure('Name','Received Coherent DSBSC 10 SNR in Frequency domain');
% stem(f, abs(coherent_f_sc_10snr));
f_filtered = f;
f_filtered((f_filtered > 10000) | (f_filtered < -10000)) = 0;
coherent_f_sc_filtered_10snr = 0.01 * (coherent_f_sc_10snr .* f_filtered');
coherent_t_sc_filtered_10snr = ifft(coherent_f_sc_filtered_10snr);
% figure('Name','Received Filtered Coherent DSBSC 10 SNR in Time domain');
% plot(t, real(coherent_t_sc_filtered_10snr));
% title('Received Filtered Coherent DSBSC 10 SNR in Time domain F = 1.001MHZ')
% xlabel('time')
% ylabel('amplitude')
% sound(abs(coherent_t_sc_filtered_10snr), Fs);
% figure('Name','Received Filtered Coherent DSBSC 10 SNR in Frequency domain F = 1.001MHZ');
% stem(f, abs(coherent_f_sc_filtered_10snr));
% title('Received Filtered Coherent DSBSC 10 SNR in Frequency domain F = 1.001MHZ')
% xlabel('frequency')
% ylabel('amplitude')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 10 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 11 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
modulated_signal_t_sc_10snr = awgn(modulated_signal_t_sc, 10);
% modulated_signal_t_sc_10snr = (modulated_signal_t_sc);
coherent_t_sc_10snr = modulated_signal_t_sc_10snr .* (cos(Wc .* t + 100))';
coherent_f_sc_10snr = fft(coherent_t_sc_10snr);
% figure('Name','Received Coherent DSBSC 10 SNR in Time domain');
% plot(t, real(coherent_t_sc_10snr));
% figure('Name','Received Coherent DSBSC 10 SNR in Frequency domain');
% stem(f, abs(coherent_f_sc_10snr));
f_filtered = f;
f_filtered((f_filtered > 10000) | (f_filtered < -10000)) = 0;
coherent_f_sc_filtered_10snr = 0.01 * (coherent_f_sc_10snr .* f_filtered');
coherent_t_sc_filtered_10snr = ifft(coherent_f_sc_filtered_10snr);
% sound(abs(coherent_t_sc_filtered_10snr), Fs);
% figure('Name','Received Filtered Coherent DSBSC 10 SNR in Time domain');
% plot(t, real(coherent_t_sc_filtered_10snr));
% title('Received Filtered Coherent DSBSC 10 SNR in Time domain Phase error = 100')
% xlabel('time')
% ylabel('amplitude')
% figure('Name','Received Filtered Coherent DSBSC 10 SNR in Frequency domain');
% stem(f, abs(coherent_f_sc_filtered_10snr));
% title('Received Filtered Coherent DSBSC 10 SNR in Frequency domain Phase error = 100')
% xlabel('frequency')
% ylabel('amplitude')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 11 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 12 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% power_efficiency_sc = (sum(p)  -  2 * p(find(f==0))) / sum(p);
power_efficiency_sc = (sum(abs(modulated_signal_f_sc))) / sum(abs(modulated_signal_f_sc))
% power_efficiency_tc = (sum(p)  -  2 * p(find(f==0))) / sum(p);
power_efficiency_tc = (sum(abs(modulated_signal_f_tc))  -  0.5 * Vc^2) / sum(abs(modulated_signal_f_tc))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 12 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
