function [freqVector, freqSignal] = fourier_analysis(timeVector, signal, L)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Returns the power spectrum density of a real signal. 
%
% ARGUMENTS: 
% time vector - should have an even length
% signal - to be transformed
%
% OUTPUT:
% freqVector
% freqSignal
%
% REQUIRES:
% none
%
% USAGE:
%{
    see tester_fourier_analysis
%}
%
% Authors:
% Ido Marcus
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    T = length(timeVector);
    Fs = 1/(timeVector(2)-timeVector(1));                   % Sampling frequency (Hz)

    if nargin < 3
        L  = length(timeVector);                                % length of signal   (number)    
    end
    
    freqSignal = fftshift(fft(signal, L));                     % perform fft and zero-centred shift   
    
   freqSignal = abs(freqSignal/(T*Fs)).^2;                         % Normalize and calculate power spectrum (no complex numbers)
%     freqSignal = (abs(freqSignal))/(L*Fs);                         % calculate power per unit frequency (ZK) - for power spectrum square this .^2
   

    freqSignal = freqSignal(L/2:end);                       % given that the signal is real, one side is enough
    freqSignal(2:end) = 2*freqSignal(2:end);                % double it (only the zero frequency doesn't appear twice)

    freqVector = Fs*(0:(L/2))'/L;                            % construction of frequency axis  