function Hd = kaizer202
%KAIZER201 返回离散时间滤波器对象。

% MATLAB Code
% Generated by MATLAB(R) 23.2 and DSP System Toolbox 23.2.
% Generated on: 09-Dec-2024 23:10:13

% FIR Window Lowpass filter designed using the FIR1 function.

% All frequency values are normalized to 1.

N    = 201;        % Order
% Fc   = 0.20485;        % Cutoff Frequency
Fc=0.2;
flag = 'noscale';  % Sampling Flag
Beta = 7.85726;    % Window Parameter

% Create the window vector for the design algorithm.
win = kaiser(N+1, Beta);

% Calculate the coefficients using the FIR1 function.
b  = fir1(N, Fc, 'low', win, flag);
Hd = dfilt.dffir(b);

% [EOF]