%% 清空环境
clc;clear;
%% 参数设置
%信号初始采样率为fs=15MHz
fs=15e6;
%采样率fsi代表内插器后的采样率
fsi=45e6;
%最终采样率ff
ff=9e6;
%% 设置时间轴
% 方便作图,信号需要几百个采样点就可以了，因此信号时间为0.1ms内即可
t1=0:1/fs:1e-4-1/fs;
t2=0:1/fsi:1e-4-1/fsi;
t3=0:1/ff:1e-4-1/ff;
%% 频率轴 %用于归一化频率，但是没使用该变量
% w1=2*pi*f/fs;
% w2=2*pi*f/fsi;
% w3=2*pi*f/fsi;
%% 测试信号采样序列
%为了不在采样时发生混叠且更好查看系统的效果，采取小于7.5MHz频率的一系列余弦信号
% 相当于从500khz不断增加500khz,直至加到7000khz
% 信号固定相位，固定幅度为1
signal=0;
for w=0.25:0.25:7.25
    signal = signal + sin(2 * pi * w * 1e6 * t1);%已经用t1时间向量采了样
end
%信号随机相位
%% 时域绘制采样序列
% 时域绘制采样信号（连续）
figure;
subplot(2, 1, 1);
plot(t1(1:1000), signal(1:1000));
xlabel('时间 (秒)');
ylabel('幅度');
title('测试信号 - 时域');
grid on;
%所有余弦信号周期的最小公倍数为4e-6,即为复合信号的周期,5个信号周期为0.02ms,20μs
%时域绘制采样序列
subplot(2, 1, 2);
stem(t1(1:200)*fs, signal(1:200), 'filled');
xlabel('样本序号');
ylabel('幅度');
title('采样后的信号序列');
grid on;
%采样率为15MHz，周期为 1/15 μs，所以采60个点为20微秒，为复合信号周期的5倍
%60/15MHz=4e-6s
%% 绘制采样序列频谱
% 计算频谱
ls = length(signal);            % 信号长度
Xs = fft(signal);               % 计算快速傅里叶变换
sfs = abs(fftshift(Xs)/ls);       % 双边频谱
f1 = (-ls/2:ls/2-1)*(fs/ls);       % 频率
% 在频域中绘制信号
figure;
subplot(2, 1, 1);
plot(f1/1e6, sfs);
xlabel('频率 (MHz)');
ylabel('幅度');
title('信号序列频谱'); 
grid on;
subplot(2, 1, 2);
plot(2*f1/fs, sfs);
xlabel('归一化频率 (\times\pi rad/sample)');
ylabel('幅度');
title('信号序列归一化频谱'); 
grid on;
%% 插值操作
si = upsample(signal, 3);%使用函数插值
figure;
subplot(2, 2, 1);
stem(t1(1:200)*fs, signal(1:200));
xlabel('样本序号');
ylabel('幅度');
title('插值前的信号序列');
grid on;
subplot(2, 2, 2);
stem(t1(1:200)*fs, si(1:200)');
xlabel('样本序号');
ylabel('幅度');
title('插值后的信号序列');
grid on;
%此时时间轴尺度不变，意味着1.2e-5s（12微秒）为一个周期
%% 插值后序列频谱
lsi = length(si);            % 信号长度
Xsi = fft(si);               % 计算快速傅里叶变换
sfsi = abs(fftshift(Xsi)/ls);       % 双边频谱
f2 = (-lsi/2:lsi/2-1)*(fsi/lsi);       % 频率
subplot(2, 2, 3);
plot(f2/1e6, sfsi);
xlabel('频率 (MHz)');
ylabel('幅度');
title('插值后信号序列频谱'); 
grid on;
subplot(2, 2, 4);
plot(2*f2/fsi, sfsi);
xlabel('归一化频率 (\times\pi rad/sample)');
ylabel('幅度');
title('插值后信号序列归一化频谱'); 
grid on;
%发现周期延拓为为原来3倍
%% 低通滤波器参数
% wp=pi/5;%滤波器通带截止频率
% ws=pi/4;%滤波器阻带截止频率
%计算得到hann窗阶数为124，Blackman窗阶数为220
%% 低通滤波
s_hann= filter(hann124,si); 
s_blackman= filter(blackman220,si); 
s_kaizer90= filter(kaizer90,si); 
s_kaizer146= filter(kaizer146,si); 
s_kaizer202= filter(kaizer202,si); 
%% 低通滤波后的序列
figure;
% 每两个样本点之间距离为2.22e-8s，为45MHz采样率下的采样周期
subplot(5,1,1);
stem(t2(1:500)*fsi, s_hann(1:500), 'filled');
xlabel('样本序号');
ylabel('幅度');
title('hann窗滤波后的信号序列');
grid on;
subplot(5,1,2);
stem(t2(1:500)*fsi, s_blackman(1:500), 'filled');
xlabel('样本序号');
ylabel('幅度');
title('blackman窗滤波后的信号序列');
grid on;
subplot(5,1,3);
stem(t2(1:500)*fsi, s_kaizer90(1:500), 'filled');
xlabel('样本序号');
ylabel('幅度');
title('kaiser90窗滤波后的信号序列');
grid on;
subplot(5,1,4);
stem(t2(1:500)*fsi, s_kaizer146(1:500), 'filled');
xlabel('样本序号');
ylabel('幅度');
title('kaiser146窗滤波后的信号序列');
grid on;
subplot(5,1,5);
stem(t2(1:500)*fsi, s_kaizer202(1:500), 'filled');
xlabel('样本序号');
ylabel('幅度');
title('kaiser202窗滤波后的信号序列');
grid on;
%发现阶数越大时延越高，此部分为无效序列
% 分析幅值相应和相频响应，Kaiser窗选择 阶，对比hann，blackman，kaiser窗
%% 滤波后信号序列傅里叶变换
lsh=length(s_hann);
f3 = (-lsh/2:lsh/2-1)*(fsi/lsh);       % 频率
Xs_hann = fft(s_hann);               % 计算快速傅里叶变换
sfsh = abs(fftshift(Xs_hann)/lsh);       % 双边频谱
Xs_blackman = fft(s_blackman);  
sfsb = abs(fftshift(Xs_blackman)/lsh); 
Xs_kaizer90 = fft(s_kaizer90);  
sfsk90 = abs(fftshift(Xs_kaizer90)/lsh); 
Xs_kaizer146 = fft(s_kaizer146);  
sfsk146 = abs(fftshift(Xs_kaizer146)/lsh); 
Xs_kaizer202 = fft(s_kaizer202);  
sfsk202 = abs(fftshift(Xs_kaizer202)/lsh); 
%% 滤波后信号序列频谱分析
figure;
subplot(5, 2, 1);
plot(f3/1e6, sfsh);
xlabel('频率 (MHz)');
ylabel('幅度');
title('hann窗滤波后信号序列频谱'); 
grid on;
subplot(5, 2, 2);
plot(2*f3/fsi, sfsh);
xlabel('归一化频率 (\times\pi rad/sample)');
ylabel('幅度');
title('hann窗滤波后信号序列归一化频谱'); 
grid on;
subplot(5, 2, 3);
plot(f3/1e6, sfsb);
xlabel('频率 (MHz)');
ylabel('幅度');
title('blackman窗滤波后信号序列频谱'); 
grid on;
subplot(5, 2, 4);
plot(2*f3/fsi, sfsb);
xlabel('归一化频率 (\times\pi rad/sample)');
ylabel('幅度');
title('blackman窗滤波后信号序列归一化频谱'); 
grid on;
subplot(5, 2, 5);
plot(f3/1e6, sfsk90);
xlabel('频率 (MHz)');
ylabel('幅度');
title('kaiser90窗滤波后信号序列频谱'); 
grid on;
subplot(5, 2, 6);
plot(2*f3/fsi, sfsk90);
xlabel('归一化频率 (\times\pi rad/sample)');
ylabel('幅度');
title('kaiser90窗滤波后信号序列归一化频谱'); 
grid on;
subplot(5, 2, 7);
plot(f3/1e6, sfsk146);
xlabel('频率 (MHz)');
ylabel('幅度');
title('kaiser146窗滤波后信号序列频谱'); 
grid on;
subplot(5, 2, 8);
plot(2*f3/fsi, sfsk146);
xlabel('归一化频率 (\times\pi rad/sample)');
ylabel('幅度');
title('kaiser146窗滤波后信号序列归一化频谱'); 
grid on;
subplot(5, 2, 9);
plot(f3/1e6, sfsk202);
xlabel('频率 (MHz)');
ylabel('幅度');
title('kaiser202窗滤波后信号序列频谱'); 
grid on;
subplot(5, 2, 10);
plot(2*f3/fsi, sfsk202);
xlabel('归一化频率 (\times\pi rad/sample)');
ylabel('幅度');
title('kaiser202窗滤波后信号序列归一化频谱'); 
grid on;
% 减采样
sdh=downsample(s_hann,5);
sdb=downsample(s_blackman,5);
sdk90=downsample(s_kaizer90,5);
sdk146=downsample(s_kaizer146,5);
sdk202=downsample(s_kaizer202,5);
%% 减采样后序列
figure;
subplot(2, 3, 1);
stem(t3(1:100)*ff, sdh(1:100), 'filled');
xlabel('样本序号');
ylabel('幅度');
title('hann减采样后的信号序列');
grid on;
subplot(2, 3, 2);
stem(t3(1:100)*ff, sdb(1:100), 'filled');
xlabel('样本序号');
ylabel('幅度');
title('blackman减采样后信号序列');
grid on;
subplot(2, 3, 4);
stem(t3(1:100)*ff, sdk90(1:100), 'filled');
xlabel('样本序号');
ylabel('幅度');
title('kaizer90减采样后信号序列');
grid on;
subplot(2, 3, 5);
stem(t3(1:100)*ff, sdk146(1:100), 'filled');
xlabel('样本序号');
ylabel('幅度');
title('kaizer146减采样后信号序列');
grid on;
subplot(2, 3, 6);
stem(t3(1:100)*ff, sdk202(1:100), 'filled');
xlabel('样本序号');
ylabel('幅度');
title('kaiser202减采样后信号序列');
grid on;
%% 直接使用9MHZ采样率采样的信号
s_rs=0;
for w=0.25:0.25:7.25
    s_rs = s_rs + sin(2 * pi * w * 1e6 * t3);%用t3时间向量直接采样
end
subplot(2,3,3);
stem(t3(1:100)*ff, s_rs(1:100), 'filled');
xlabel('样本序号');
ylabel('幅度');
title('直接9MHz采样的信号序列');
grid on;
%% 减采样后序列频谱
lsd=length(sdh);
f3 = (-lsd/2:lsd/2-1)*(ff/lsd);       % 频率
% hann
Xsdh = fft(sdh);               % 计算快速傅里叶变换
sfsdh = abs(fftshift(Xsdh)/lsd);       % 双边频谱
figure;
subplot(2, 2, 1);
plot(f3/1e6, sfsdh);
xlabel('频率 (MHz)');
ylabel('幅度');
title('hann重采样信号序列频谱'); 
grid on;
subplot(2, 2, 2);
plot(2*f3/ff, sfsdh);
xlabel('归一化频率 (\times\pi rad/sample)');
ylabel('幅度');
title('hann重采样信号序列归一化频谱'); 
grid on;
% blackman
Xsdb = fft(sdb);               % 计算快速傅里叶变换
sfsdb = abs(fftshift(Xsdb)/lsd);       % 双边频谱
subplot(2, 2, 3);
plot(f3/1e6, sfsdb);
xlabel('频率 (MHz)');
ylabel('幅度');
title('blackman重采样信号序列频谱'); 
grid on;
subplot(2, 2, 4);
plot(2*f3/ff, sfsdb);
xlabel('blackman归一化频率 (\times\pi rad/sample)');
ylabel('幅度');
title('blackman重采样信号序列归一化频谱'); 
grid on;
%% kaiser窗频谱
% kaiser90
Xsdk90 = fft(sdk90);               % 计算快速傅里叶变换
sfsdk90 = abs(fftshift(Xsdk90)/lsd);       % 双边频谱
figure;
subplot(3, 2, 1);
plot(f3/1e6, sfsdk90);
xlabel('频率 (MHz)');
ylabel('幅度');
title('kaiser90重采样信号序列频谱'); 
grid on;
subplot(3, 2, 2);
plot(2*f3/ff, sfsdk90);
xlabel('归一化频率 (\times\pi rad/sample)');
ylabel('幅度');
title('kaiser90重采样信号序列归一化频谱'); 
grid on;
%kaiser146
Xsdk146 = fft(sdk146);               % 计算快速傅里叶变换
sfsdk146 = abs(fftshift(Xsdk146)/lsd);       % 双边频谱
subplot(3, 2, 3);
plot(f3/1e6, sfsdk146);
xlabel('频率 (MHz)');
ylabel('幅度');
title('kaiser146重采样信号序列频谱'); 
grid on;
subplot(3, 2, 4);
plot(2*f3/ff, sfsdk146);
xlabel('归一化频率 (\times\pi rad/sample)');
ylabel('幅度');
title('kaiser146重采样信号序列归一化频谱'); 
grid on;
%kaiser202
Xsdk202 = fft(sdk202);               % 计算快速傅里叶变换
sfsdk202 = abs(fftshift(Xsdk202)/lsd);       % 双边频谱
subplot(3, 2, 5);
plot(f3/1e6, sfsdk202);
xlabel('频率 (MHz)');
ylabel('幅度');
title('kaiser202重采样信号序列频谱'); 
grid on;
subplot(3, 2, 6);
plot(2*f3/ff, sfsdk202);
xlabel('归一化频率 (\times\pi rad/sample)');
ylabel('幅度');
title('kaiser202重采样信号序列归一化频谱'); 
grid on;
%% Parks-McClellan算法设计的滤波器进行滤波
s_pm= filter(Parks_McClellanfilter,si); 
%% 信号序列
figure;
subplot(1,2,1);
stem(t2(1:500)*fsi, s_pm(1:500), 'filled');
xlabel('样本序号');
ylabel('幅度');
title('pm算法设计滤波器滤波后的信号序列');
grid on;
%% 滤波后的频谱
Xs_pm = fft(s_pm);               % 计算快速傅里叶变换
sfs_pm = abs(fftshift(Xs_pm)/lsh);       % 双边频谱
lsfs_pm=length(sfs_pm);
f4 = (-lsfs_pm/2:lsfs_pm/2-1)*(fsi/lsfs_pm); 
subplot(1,2,2);
plot(f4/1e6, sfs_pm);
xlabel('频率 (MHz)');
ylabel('幅度');
title('pm算法滤波后信号序列频谱'); 
grid on;
%减采样
sdpm=downsample(s_pm,5);
%序列
figure;
subplot(1,2,1);
stem(t3(50:150)*ff, sdpm(50:150), 'filled');
xlabel('样本序号');
ylabel('幅度');
title('pm算法滤波器减采样后的信号序列');
grid on;
%频谱
lsdpm=length(sdpm);
f5 = (-lsdpm/2:lsdpm/2-1)*(ff/lsdpm);       % 频率
Xsdpm = fft(sdpm);               % 计算快速傅里叶变换
sfsdh = abs(fftshift(Xsdpm)/lsdpm);       % 双边频谱
subplot(1, 2, 2);
plot(f5/1e6, sfsdh);
xlabel('频率 (MHz)');
ylabel('幅度');
title('pm算法滤波器重采样信号序列频谱'); 
grid on;
freqz(Parks_McClellanfilter);