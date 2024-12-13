function Hd = kaizer146
%KAIZER145 返回离散时间滤波器对象。

% MATLAB Code
% Generated by MATLAB(R) 23.2 and DSP System Toolbox 23.2.
% Generated on: 09-Dec-2024 23:10:57

% FIR Window Lowpass filter designed using the FIR1 function.

% All frequency values are normalized to 1.

N    = 145;        % Order
% Fc   = 0.2058;        % Cutoff Frequency
Fc=0.2;
flag = 'noscale';  % Sampling Flag
Beta = 5.65326;    % Window Parameter

% Create the window vector for the design algorithm.
win = kaiser(N+1, Beta);

% Calculate the coefficients using the FIR1 function.
b  = fir1(N, Fc, 'low', win, flag);
Hd = dfilt.dffir(b);

% [EOF]
