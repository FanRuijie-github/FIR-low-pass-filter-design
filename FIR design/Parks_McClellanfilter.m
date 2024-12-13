%% Parks-McClellan 算法下的FIR 滤波器设计
% 滤波器参数
function Hd=Parks_McClellanfilter
Fs = 15e6;          % 采样频率 (Hz)
Fpass = 1.435e6;    % 通带截止频率
Fstop = 1.55e6;     % 阻带起始频率
Rp = 0.001;         % 通带波纹 (dB)
Rs = 60;            % 阻带衰减 (dB)
f = [Fpass Fstop];  % 归一化频率
a = [1 0];          % 理想幅频响应
dev = [(10^(Rp/20)-1)/(10^(Rp/20)+1) , 10^(-Rs/20)]; % 容忍误差
[n, fo, ao, w] = firpmord(f, a, dev,Fs);             % 估计滤波器阶数
b = firpm(n, fo, ao, w);                             % 设计滤波器
Hd = dfilt.dffir(b);                                 % 生成滤波器对象