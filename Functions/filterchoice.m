function Hd=filterchoice(NO_IMF)
switch NO_IMF
    case 1
        Hd=FILTER1; 
    case 2
        Hd=FILTER2; 
    case 3
        Hd=FILTER3; 
    case 4
        Hd=FILTER4; 
    otherwise
        Hd=FILTER5; 
end

function Hd = FILTER1
% -------------------------------------------------------------------------
% All frequency values are in Hz.
Fs = 360;  % Sampling Frequency
% -------------------------------------------------------------------------
N     = 50;       % Order
Fc    = 55;
flag  = 'scale';  % Sampling Flag
% Create the window vector for the design algorithm.
win = hamming(N+1);
% Calculate the coefficients using the FIR1 function.
b  = fir1(N, Fc/(Fs/2), 'low', win, flag);
Hd = dfilt.dffir(b);

function Hd = FILTER2
% -------------------------------------------------------------------------
% All frequency values are in Hz.
Fs = 360;  % Sampling Frequency
% -------------------------------------------------------------------------
N     = 50;       % Order
Fc    = 50;
flag  = 'scale';  % Sampling Flag
% Create the window vector for the design algorithm.
win = hamming(N+1);
% Calculate the coefficients using the FIR1 function.
b  = fir1(N, Fc/(Fs/2), 'low', win, flag);
Hd = dfilt.dffir(b);


function Hd = FILTER3
% -------------------------------------------------------------------------
% All frequency values are in Hz.
Fs = 360;  % Sampling Frequency
% -------------------------------------------------------------------------
N    = 50;       % Order
Fc   = 20;       % Cutoff Frequency
flag = 'scale';  % Sampling Flag
% Create the window vector for the design algorithm.
win = hamming(N+1);
% Calculate the coefficients using the FIR1 function.
b  = fir1(N, Fc/(Fs/2), 'low', win, flag);
Hd = dfilt.dffir(b);


function Hd = FILTER4
% -------------------------------------------------------------------------
% All frequency values are in Hz.
Fs = 360;  % Sampling Frequency
% -------------------------------------------------------------------------
N    = 80;       % Order
Fc   = 10;       % Cutoff Frequency
flag = 'scale';  % Sampling Flag
% Create the window vector for the design algorithm.
win = hamming(N+1);
% Calculate the coefficients using the FIR1 function.
b  = fir1(N, Fc/(Fs/2), 'low', win, flag);
Hd = dfilt.dffir(b);


function Hd = FILTER5
% -------------------------------------------------------------------------
% All frequency values are in Hz.
Fs = 360;  % Sampling Frequency
% -------------------------------------------------------------------------
N    = 80;       % Order
Fc   = 5;       % Cutoff Frequency
flag = 'scale';  % Sampling Flag
% Create the window vector for the design algorithm.
win = hamming(N+1);
% Calculate the coefficients using the FIR1 function.
b  = fir1(N, Fc/(Fs/2), 'low', win, flag);
Hd = dfilt.dffir(b);
