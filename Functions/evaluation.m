function out = evaluation(eval,X,C,S)

switch eval
    case 1
        out = dSER_var(X,C,S);
    case 2
        out = SER(X,C);
    case 3
        out = MSE(X,C);
    otherwise
        out = dSER(X,C,S);
end
end

% -------------------------------------------------------------------------
% DIFFERENCE of SIGNAL-to-ERROR RATIO(DSER in dB) by calculating variances of each signal
% -------------------------------------------------------------------------
function DSER = dSER_var(signal,clean,noisy)
DSER = ( 10*log10(var(signal)/var(clean))- ...
         10*log10(var(signal)/var(noisy)) );
end

% -------------------------------------------------------------------------
% SIGNAL-to-ERROR RATIO(SER) by calculating power of each signal
% -------------------------------------------------------------------------
function SERsum = SER(signal,clean)
X=signal;
N=signal-clean;
SERsum = sum(X(:).^2)/sum(N(:).^2);
end

% -------------------------------------------------------------------------
% calculating MEAN SQUARED ERROR(MSE)
% -------------------------------------------------------------------------
function mse = MSE(signal,clean)
DX=(signal-clean).^2;
mse=mean(DX);
end

% -------------------------------------------------------------------------
% DIFFERENCE of SIGNAL-to-ERROR RATIO(DSER) by calculating power of each signal
% -------------------------------------------------------------------------
function DSER = dSER(signal,clean,noisy)
e1=noisy-signal;
e2=clean-signal;

X=signal;
DSER = (sum(X(:).^2)/sum(e2(:).^2))- ...
       (sum(X(:).^2)/sum(e1(:).^2));
end