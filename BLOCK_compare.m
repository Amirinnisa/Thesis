function [OUT1 OUT2 OUT3]=BLOCK_compare(blockchoice,X,S)
    switch blockchoice 
        case 1
            %BLOCK: testing scenario 1 (MIT-BIH)
            [OUT1 OUT2 OUT3]=compare1(X,S);
        case 2
            %NO BLOCK: testing scenario 1 (MIT-BIH)
            [OUT1 OUT2]=compare2(X,S);
        case 3
            %BLOCK: testing scenario 2 (sensor data)
            [OUT1 OUT2 OUT3]=compare3(X,S);
        otherwise
            %NO BLOCK: testing scenario 2 (sensor data)
            [OUT1 OUT2]=compare4(X,S);
    end
end

%% -------------------------------------------------------------------------
% COMPARE EEMD VS EMD VS General Filter (BLOCK)
% MIT BIH database (scenario 1)
% -------------------------------------------------------------------------
% BLOCK: FIRST, MIDDLE, LAST (adjusted)
% SHIFT LENGTH (data plot) = 400 --> adjustable
%    T/OUT1 = no.of IMF, tEEMD, no.of IMF2, tBLOCK
%    EVAL/OUT2 = DSERref, DSEReemd, DSERemd, DSERgeneral
%                SERref, SEReemd, SERemd, SERgeneral, 
%                MSEref, MSEeemd, MSEemd, MSEgeneral
%    PROP/OUT3 = No. of Blocks, Block Size, Overlap(%), Display, Overlap(samples)
%    X = Reference Signals
%    S = Noisy Signals
% COMMAND: [T EVAL PROP]=BLOCK_compare(1,X,S)
function [OUT1 OUT2 OUT3]=compare1(X,S)
% -------------------------------------------------------------------------
%INITIALIZATION
% -------------------------------------------------------------------------
DATA_BLOCK = S;
REFERENCE = X;

%determining block sizes
SHIFT_LENGTH = 400;
OVERLAP = 150/100;
OVERLAP_WIN = OVERLAP*SHIFT_LENGTH;
BLOCK_SIZE = SHIFT_LENGTH+2*(OVERLAP_WIN);
SHIFT_TIMES = round((length(DATA_BLOCK)-BLOCK_SIZE)/SHIFT_LENGTH);   
% saving the block properties in OUT3
OUT3=[SHIFT_TIMES+1 BLOCK_SIZE OVERLAP SHIFT_LENGTH OVERLAP_WIN];

figure 
figures (1) = gcf;pause;
figure 
figures (2) = gcf;pause;
% for X limit in figures
    iBorder=0;
    borderX0=(1500+1)*iBorder;
    borderX1=1500*(iBorder+1);

lastdata = zeros(SHIFT_TIMES+1,10);

OUT1 = NaN(SHIFT_TIMES+1,4);
OUT2 = NaN(SHIFT_TIMES+2,12);

% -------------------------------------------------------------------------
% BLOCK PROCESSING
% -------------------------------------------------------------------------
for NO_OF_BLOCKS = 0 : SHIFT_TIMES
tic
    
    T0 = 1+(NO_OF_BLOCKS)*SHIFT_LENGTH;
    T1 = BLOCK_SIZE+(NO_OF_BLOCKS)*SHIFT_LENGTH;

    if( (T1>length(DATA_BLOCK))||(NO_OF_BLOCKS == SHIFT_TIMES)) %%check index whether extend
            T1 = length(DATA_BLOCK);
    end
    
    T=T0:T1;
    
clear datain; clear dataref; clear noiseref;
    datain  =  DATA_BLOCK(T); %save the block-data (block_size or adjusted) 
    dataref =  REFERENCE(T);
    noiseref= datain-dataref;
    
% -------------------------------------------------------------------------
% EXTRACT IMFs
% -------------------------------------------------------------------------
    [t_eemd,IMF1] = rcada_eemd(datain, 0.2, 100, -1);
    NO_IMF = size(IMF1);
    
    IMF2 = rcada_emd(datain, 1, 2, -1, 10); IMF2=IMF2';
    NO_IMF2 = size(IMF2);
    
% -------------------------------------------------------------------------
% FILTER
% -------------------------------------------------------------------------
    %1. EEMD (Proposed Method)
    [CLEAN NOISE , ~, ~] = trial_filter(1, datain,IMF1);
    %2. EMD
    [CLEAN2 NOISE2 , ~, ~] = trial_filter(1, datain,IMF2);
    %3. General Filter (using BPF FIR gaussian-windows)
    [CLEAN3 NOISE3] = trial_filter(2, datain);
    
% -------------------------------------------------------------------------
% PLOT ; BLOCK TYPES (FIRST, MIDDLE, LAST); HANDLING DATA BETWEEN BLOCKS
% -------------------------------------------------------------------------
%Handling data between block in plotting (using lastdata array)
    if (NO_OF_BLOCKS==0)
    % FIRST BLOCK
        Tplot = T0:(T1-OVERLAP_WIN);
        Rplot = 1:(OVERLAP_WIN+SHIFT_LENGTH);
        lastdata(1,:) = [Tplot(1)   dataref(Rplot(1))   datain(Rplot(1)) noiseref(Rplot(1)) ...
                CLEAN(:,Rplot(1)) NOISE(:,Rplot(1)) CLEAN2(:,Rplot(1)) NOISE2(:,Rplot(1)) ...
                CLEAN3(:,Rplot(1)) NOISE3(:,Rplot(1))];
        lastdata(NO_OF_BLOCKS+2,:) = [Tplot(end) dataref(Rplot(end)) datain(Rplot(end)) noiseref(Rplot(end)) ...
                CLEAN(:,Rplot(end)) NOISE(:,Rplot(end)) CLEAN2(:,Rplot(end)) NOISE2(:,Rplot(end)) ...
                CLEAN3(:,Rplot(end)) NOISE3(:,Rplot(end))];
    else if ((NO_OF_BLOCKS==SHIFT_TIMES))
    % LAST BLOCK
        Tplot = (T0+OVERLAP_WIN):T1;
        Rplot = (OVERLAP_WIN+1):(length(T));
        else
    % MIDDLE BLOCK
            Tplot = (T0+OVERLAP_WIN):(T1-OVERLAP_WIN);
            Rplot = (OVERLAP_WIN+1):(OVERLAP_WIN+SHIFT_LENGTH);        
            lastdata(NO_OF_BLOCKS+2,:) = [Tplot(end) dataref(Rplot(end)) datain(Rplot(end)) noiseref(Rplot(end)) ...
                CLEAN(:,Rplot(end)) NOISE(:,Rplot(end)) CLEAN2(:,Rplot(end)) NOISE2(:,Rplot(end)) ...
                CLEAN3(:,Rplot(end)) NOISE3(:,Rplot(end))];
        end
    end
    
% Handling window size in figures
if  (lastdata(NO_OF_BLOCKS+1,1)>borderX1)|(Tplot>borderX1)
    pause(0.1);
    iBorder=iBorder+1;
    borderX0=(1500+1)*iBorder;
    borderX1=1500*(iBorder+1);
end

%The Figures
figure(figures(1))
    subplot(311), plot([lastdata(NO_OF_BLOCKS+1,1) Tplot],[lastdata(NO_OF_BLOCKS+1, 2) dataref(Rplot)],'k'),
        title('REFERENCE & NOISY SIGNAL');    
        hold on;xlim([borderX0 borderX1]);grid on;
        ylabel('amplitude');xlabel('samples'); legend('REFERENCE');
    subplot(312), plot([lastdata(NO_OF_BLOCKS+1,1) Tplot],[lastdata(NO_OF_BLOCKS+1, 3) datain(Rplot)]);    
        hold on;xlim([borderX0 borderX1]);grid on;
        ylabel('amplitude');xlabel('samples');legend('noisy');
    subplot(313), plot([lastdata(NO_OF_BLOCKS+1,1) Tplot],[lastdata(NO_OF_BLOCKS+1, 4) noiseref(Rplot)],'r');    
        hold on;xlim([borderX0 borderX1]);grid on;
        ylabel('amplitude');xlabel('samples');legend('noise');
        
figure(figures(2))
    subplot(231), plot([lastdata(NO_OF_BLOCKS+1,1) Tplot],[lastdata(NO_OF_BLOCKS+1, 5) CLEAN(:,Rplot)]),
    title('Comparison: EEMD, EMD, General Filter (Overlap 100%, Block size 1000)');
        hold on;xlim([borderX0 borderX1]);grid on;
        ylabel('amplitude');xlabel('samples'); legend('CLEAN - EEMD');
    subplot(232), plot([lastdata(NO_OF_BLOCKS+1,1) Tplot],[lastdata(NO_OF_BLOCKS+1, 7) CLEAN2(:,Rplot)])
        hold on;xlim([borderX0 borderX1]);grid on;
        ylabel('amplitude');xlabel('samples'); legend('CLEAN - EMD');
    subplot(233), plot([lastdata(NO_OF_BLOCKS+1,1) Tplot],[lastdata(NO_OF_BLOCKS+1, 9) CLEAN3(:,Rplot)])
        hold on;xlim([borderX0 borderX1]);grid on;
        ylabel('amplitude');xlabel('samples'); legend('CLEAN - General Filter');
    subplot(234), plot([lastdata(NO_OF_BLOCKS+1,1) Tplot],[lastdata(NO_OF_BLOCKS+1, 6) NOISE(:,Rplot)],'r');
        hold on;xlim([borderX0 borderX1]);grid on;
        ylabel('amplitude');xlabel('samples'); legend('NOISE - EEMD');
    subplot(235), plot([lastdata(NO_OF_BLOCKS+1,1) Tplot],[lastdata(NO_OF_BLOCKS+1, 8) NOISE2(:,Rplot)],'r');
        hold on;xlim([borderX0 borderX1]);grid on;
        ylabel('amplitude');xlabel('samples'); legend('NOISE - EMD');
    subplot(236), plot([lastdata(NO_OF_BLOCKS+1,1) Tplot],[lastdata(NO_OF_BLOCKS+1,10) NOISE3(:,Rplot)],'r');
        hold on;xlim([borderX0 borderX1]);grid on;
        ylabel('amplitude');xlabel('samples'); legend('NOISE - General Filter');

% -------------------------------------------------------------------------
% EVALUATION
% -------------------------------------------------------------------------
    %DSER -> no dB: calculated using DSER
    OUT2(NO_OF_BLOCKS+1,1)=evaluation(4,dataref,datain,datain);
    OUT2(NO_OF_BLOCKS+1,2)=evaluation(4,dataref,CLEAN ,datain);
    OUT2(NO_OF_BLOCKS+1,3)=evaluation(4,dataref,CLEAN2,datain);
    OUT2(NO_OF_BLOCKS+1,4)=evaluation(4,dataref,CLEAN3,datain);
    %SER -> no dB
    OUT2(NO_OF_BLOCKS+1,5)=evaluation(2,dataref,datain);
    OUT2(NO_OF_BLOCKS+1,6)=evaluation(2,dataref,CLEAN );
    OUT2(NO_OF_BLOCKS+1,7)=evaluation(2,dataref,CLEAN2);
    OUT2(NO_OF_BLOCKS+1,8)=evaluation(2,dataref,CLEAN3);
    % MSE
    OUT2(NO_OF_BLOCKS+1, 9)=evaluation(3,dataref,datain);
    OUT2(NO_OF_BLOCKS+1,10)=evaluation(3,dataref,CLEAN );
    OUT2(NO_OF_BLOCKS+1,11)=evaluation(3,dataref,CLEAN2);
	OUT2(NO_OF_BLOCKS+1,12)=evaluation(3,dataref,CLEAN3);

% -------------------------------------------------------------------------
% SAVE THE TIME & NUMBER OF IMFs
% -------------------------------------------------------------------------
OUT1(NO_OF_BLOCKS+1,1)=NO_IMF(1);    
OUT1(NO_OF_BLOCKS+1,2)=t_eemd;
OUT1(NO_OF_BLOCKS+1,3)=NO_IMF2(1);    
OUT1(NO_OF_BLOCKS+1,4)=toc;
end
%End of the Block Processing

% calculating average values of all evaluation measures 
% put in the last line of OUT2
    OUT2(SHIFT_TIMES+2,:)=mean(OUT2(1:SHIFT_TIMES+1,:));

end

%% -------------------------------------------------------------------------
% COMPARE EEMD VS EMD VS General Filter (NO BLOCK)
% MIT BIH database (scenario 1)
% -------------------------------------------------------------------------
% NO BLOCK: all data processed in ONE time (together)
%    T/OUT1 = no.of IMF, tEEMD, no.of IMF2, tBLOCK
%    EVAL/OUT2 = DSERref, DSEReemd, DSERemd, DSERgeneral
%                SERref, SEReemd, SERemd, SERgeneral, 
%                MSEref, MSEeemd, MSEemd, MSEgeneral
%    X = Reference Signals
%    S = Noisy Signals
% COMMAND: [T EVAL] = BLOCK_compare(2,X,S)
function [OUT1 OUT2]=compare2(X,S) 
% -------------------------------------------------------------------------
%INITIALIZATION
% -------------------------------------------------------------------------
tic
figure 
figures (1) = gcf;
figure 
figures (2) = gcf;

OUT1 = NaN(1, 4); 
OUT2 = NaN(1,12);

% -------------------------------------------------------------------------
% NO BLOCK PROCESSING
% -------------------------------------------------------------------------
T=1:length(X);

datain  =  S; %save the block-data (block_size or adjusted)
dataref =  X;
noiseref= datain-dataref;
    
% -------------------------------------------------------------------------
% EXTRACT IMFs
% -------------------------------------------------------------------------
    [t_eemd,IMF1] = rcada_eemd(datain, 0.2, 100, -1);
    NO_IMF = size(IMF1);
    
    IMF2 = rcada_emd(datain, 1, 2, -1, 10); IMF2=IMF2';
    NO_IMF2 = size(IMF2);
    
% -------------------------------------------------------------------------
% FILTER
% -------------------------------------------------------------------------
    %1. EEMD (Proposed Method)
    [CLEAN NOISE , ~, ~] = trial_filter(1, datain,IMF1);
	%2. EMD
    [CLEAN2 NOISE2 , ~, ~] = trial_filter(1, datain,IMF2);
    %3. General Filter (using BPF FIR gaussian-windows)
    [CLEAN3 NOISE3] = trial_filter(2, datain);
    
% -------------------------------------------------------------------------
% PLOT
% -------------------------------------------------------------------------    
%The Figures
figure(figures(1))
    subplot(311), plot(T,dataref(T),'k'),title('REFERENCE & NOISY SIGNAL');    
        grid on; ylabel('amplitude');xlabel('samples'); legend('REFERENCE');
    subplot(312), plot(T,datain(T));    
        grid on;ylabel('amplitude');xlabel('samples');legend('noisy');
    subplot(313), plot(T,noiseref(T),'r');    
        grid on;ylabel('amplitude');xlabel('samples');legend('noise');
        
figure(figures(2))
    subplot(231), plot(T,CLEAN(T)),
    title('Comparison: EEMD, EMD, General Filter (NO BLOCK)');
        grid on;ylabel('amplitude');xlabel('samples'); legend('CLEAN - EEMD');
    subplot(232), plot(T,CLEAN2(T));
        grid on;ylabel('amplitude');xlabel('samples'); legend('CLEAN - EMD');
    subplot(233), plot(T,CLEAN3(T));
        grid on;ylabel('amplitude');xlabel('samples'); legend('CLEAN - General Filter');
    subplot(234), plot(T,NOISE(T),'r');
        grid on;ylabel('amplitude');xlabel('samples');legend('NOISE - EEMD');
    subplot(235), plot(T,NOISE2(T),'r');
        grid on;ylabel('amplitude');xlabel('samples');legend('NOISE - EMD');
    subplot(236), plot(T,NOISE3(T),'r');
        grid on;ylabel('amplitude');xlabel('samples');legend('NOISE - General Filter');
% -------------------------------------------------------------------------
% EVALUATION
% -------------------------------------------------------------------------    
    %DSER -> no dB: calculated using DSER
    OUT2(1,1)=evaluation(4,dataref,datain,datain);
    OUT2(1,2)=evaluation(4,dataref,CLEAN ,datain);
    OUT2(1,3)=evaluation(4,dataref,CLEAN2,datain);
    OUT2(1,4)=evaluation(4,dataref,CLEAN3,datain);
    %SER -> no dB
    OUT2(1,5)=evaluation(2,dataref,datain);
    OUT2(1,6)=evaluation(2,dataref,CLEAN );
    OUT2(1,7)=evaluation(2,dataref,CLEAN2);
    OUT2(1,8)=evaluation(2,dataref,CLEAN3);
    % MSE
    OUT2(1, 9)=evaluation(3,dataref,datain);
    OUT2(1,10)=evaluation(3,dataref,CLEAN );
    OUT2(1,11)=evaluation(3,dataref,CLEAN2);
	OUT2(1,12)=evaluation(3,dataref,CLEAN3);
% -------------------------------------------------------------------------
% SAVE THE TIME & NUMBER OF IMFs
% -------------------------------------------------------------------------
OUT1(1,1)=NO_IMF(1);    
OUT1(1,2)=t_eemd;    
OUT1(1,3)=NO_IMF2(1);
OUT1(1,4)=toc;
end

%% -------------------------------------------------------------------------
% COMPARE EEMD VS EMD VS General Filter (BLOCK)
% Real Data (scenario 2)
% -------------------------------------------------------------------------
% BLOCK: FIRST, MIDDLE, LAST (adjusted)
% SHIFT LENGTH (data plot) = 400 --> adjustable
%    T/OUT1 = no.of IMF, tEEMD, no.of IMF2, tBLOCK
%    EVAL/OUT2 = DSERref, DSEReemd, DSERemd, DSERgeneral
%    PROP/OUT3 = No. of Blocks, Block Size, Overlap(%), Display, Overlap(samples)
%    X = Reference Signals
%    S = Noisy Signals
% COMMAND: [T EVAL PROP]=BLOCK_compare(3,X,S)
function [OUT1 OUT2 OUT3]=compare3(X,S)
% -------------------------------------------------------------------------
%INITIALIZATION
% -------------------------------------------------------------------------
DATA_BLOCK = S;
REFERENCE = X;

%determining block sizes
SHIFT_LENGTH = 400;
OVERLAP = 1.5;
OVERLAP_WIN = OVERLAP*SHIFT_LENGTH;
BLOCK_SIZE = SHIFT_LENGTH+2*(OVERLAP_WIN);
SHIFT_TIMES = round((length(DATA_BLOCK)-BLOCK_SIZE)/SHIFT_LENGTH);   
% saving the block properties in OUT3
OUT3=[SHIFT_TIMES+1 BLOCK_SIZE OVERLAP SHIFT_LENGTH OVERLAP_WIN];

figure 
figures (1) = gcf;
figure 
figures (2) = gcf;
% %for X limit in plotting the figure
    iBorder=0;
    borderX0=(1500+1)*iBorder;
    borderX1=1500*(iBorder+1);

lastdata = zeros(SHIFT_TIMES+1,9);

OUT1 = NaN(SHIFT_TIMES+1,4);
OUT2 = NaN(SHIFT_TIMES+2,4);

% -------------------------------------------------------------------------
% BLOCK PROCESSING
% -------------------------------------------------------------------------
for NO_OF_BLOCKS = 0 : SHIFT_TIMES
tic
    T0 = 1+(NO_OF_BLOCKS)*SHIFT_LENGTH;
    T1 = BLOCK_SIZE+(NO_OF_BLOCKS)*SHIFT_LENGTH;

    if( (T1>length(DATA_BLOCK))||(NO_OF_BLOCKS == SHIFT_TIMES)) %%check index whether extend
            T1 = length(DATA_BLOCK);
    end
    
    T=T0:T1;
    
    clear datain; clear dataref; clear noiseref;
    datain  =  DATA_BLOCK(T); %save the block-data (block_size or adjusted)
    dataref =  REFERENCE(T);
    
% -------------------------------------------------------------------------
% EXTRACT IMFs
% -------------------------------------------------------------------------
    [t_eemd,IMF1] = rcada_eemd(datain, 0.2, 100, -1);
    NO_IMF = size(IMF1);
    
    IMF2 = rcada_emd(datain, 1, 2, -1, 10); IMF2=IMF2';
    NO_IMF2 = size(IMF2);
    
% -------------------------------------------------------------------------
% FILTER
% -------------------------------------------------------------------------
    %1. EEMD (Proposed Method)
    [CLEAN NOISE , ~, ~] = trial_filter(3, datain,IMF1);
    %2. EMD
    [CLEAN2 NOISE2 , ~, ~] = trial_filter(3, datain,IMF2);
    %3. General Filter (using BPF FIR gaussian-windows)
    [CLEAN3 NOISE3] = trial_filter(4, datain);
    
% -------------------------------------------------------------------------
% PLOT ; BLOCK TYPES (FIRST, MIDDLE, LAST); HANDLING DATA BETWEEN BLOCKS
% -------------------------------------------------------------------------
%Handling data between block in plotting (using lastdata array)
    if (NO_OF_BLOCKS==0)
    % FIRST BLOCK
        Tplot = T0:(T1-OVERLAP_WIN);
        Rplot = 1:(OVERLAP_WIN+SHIFT_LENGTH);
        lastdata(1,:) = [Tplot(1)   dataref(Rplot(1))   datain(Rplot(1)) ...
                CLEAN(:,Rplot(1)) NOISE(:,Rplot(1)) CLEAN2(:,Rplot(1)) NOISE2(:,Rplot(1)) ...
                CLEAN3(:,Rplot(1)) NOISE3(:,Rplot(1))];
        lastdata(NO_OF_BLOCKS+2,:) = [Tplot(end) dataref(Rplot(end)) datain(Rplot(end)) ...
                CLEAN(:,Rplot(end)) NOISE(:,Rplot(end)) CLEAN2(:,Rplot(end)) NOISE2(:,Rplot(end)) ...
                CLEAN3(:,Rplot(end)) NOISE3(:,Rplot(end))];
    else if ((NO_OF_BLOCKS==SHIFT_TIMES))
    % LAST BLOCK
        Tplot = (T0+OVERLAP_WIN):T1;
        Rplot = (OVERLAP_WIN+1):(length(T));
        else
    % MIDDLE BLOCK
            Tplot = (T0+OVERLAP_WIN):(T1-OVERLAP_WIN);
            Rplot = (OVERLAP_WIN+1):(OVERLAP_WIN+SHIFT_LENGTH);        
            lastdata(NO_OF_BLOCKS+2,:) = [Tplot(end) dataref(Rplot(end)) datain(Rplot(end)) ...
                CLEAN(:,Rplot(end)) NOISE(:,Rplot(end)) CLEAN2(:,Rplot(end)) NOISE2(:,Rplot(end)) ...
                CLEAN3(:,Rplot(end)) NOISE3(:,Rplot(end))];
        end
    end 
    
% Handling window size in figures   
if  (lastdata(NO_OF_BLOCKS+1,1)>borderX1)|(Tplot>borderX1)
    pause(0.1);
    iBorder=iBorder+1;
    borderX0=(1500+1)*iBorder;
    borderX1=1500*(iBorder+1);
end

%The Figures
figure(figures(1))
    subplot(211), plot([lastdata(NO_OF_BLOCKS+1,1) Tplot],[lastdata(NO_OF_BLOCKS+1, 2) dataref(Rplot)],'k'),
        title('REFERENCE & NOISY SIGNAL');    
        hold on;xlim([borderX0 borderX1]);grid on;
        ylabel('amplitude');xlabel('samples'); legend('REFERENCE');
    subplot(212), plot([lastdata(NO_OF_BLOCKS+1,1) Tplot],[lastdata(NO_OF_BLOCKS+1, 3) datain(Rplot)]);    
        hold on;xlim([borderX0 borderX1]);grid on;
        ylabel('amplitude');xlabel('samples');legend('NOISY');
        
figure(figures(2))
    subplot(231), plot([lastdata(NO_OF_BLOCKS+1,1) Tplot],[lastdata(NO_OF_BLOCKS+1, 4) CLEAN(:,Rplot)]),
    title('Comparison: EEMD, EMD, General Filter (Overlap 100%, Block size 1000)');
        hold on;xlim([borderX0 borderX1]);grid on;
        ylabel('amplitude');xlabel('samples'); legend('CLEAN - EEMD');
    subplot(232), plot([lastdata(NO_OF_BLOCKS+1,1) Tplot],[lastdata(NO_OF_BLOCKS+1, 6) CLEAN2(:,Rplot)])
        hold on;xlim([borderX0 borderX1]);grid on;
        ylabel('amplitude');xlabel('samples'); legend('CLEAN - EMD');
    subplot(233), plot([lastdata(NO_OF_BLOCKS+1,1) Tplot],[lastdata(NO_OF_BLOCKS+1, 8) CLEAN3(:,Rplot)])
        hold on;xlim([borderX0 borderX1]);grid on;
        ylabel('amplitude');xlabel('samples'); legend('CLEAN - General Filter');
    subplot(234), plot([lastdata(NO_OF_BLOCKS+1,1) Tplot],[lastdata(NO_OF_BLOCKS+1, 5) NOISE(:,Rplot)],'r');
        hold on;xlim([borderX0 borderX1]);grid on;
        ylabel('amplitude');xlabel('samples'); legend('NOISE - EEMD');
    subplot(235), plot([lastdata(NO_OF_BLOCKS+1,1) Tplot],[lastdata(NO_OF_BLOCKS+1, 7) NOISE2(:,Rplot)],'r');
        hold on;xlim([borderX0 borderX1]);grid on;
        ylabel('amplitude');xlabel('samples'); legend('NOISE - EMD');
    subplot(236), plot([lastdata(NO_OF_BLOCKS+1,1) Tplot],[lastdata(NO_OF_BLOCKS+1, 9) NOISE3(:,Rplot)],'r');
        hold on;xlim([borderX0 borderX1]);grid on;
        ylabel('amplitude');xlabel('samples'); legend('NOISE - General Filter');

% -------------------------------------------------------------------------
% EVALUATION
% -------------------------------------------------------------------------
    % DSER(dB): calculated using DSER_var
    OUT2(NO_OF_BLOCKS+1,1)=evaluation(1,dataref,datain,datain);
    OUT2(NO_OF_BLOCKS+1,2)=evaluation(1,dataref,CLEAN ,datain);
    OUT2(NO_OF_BLOCKS+1,3)=evaluation(1,dataref,CLEAN2,datain);
    OUT2(NO_OF_BLOCKS+1,4)=evaluation(1,dataref,CLEAN3,datain);

	% DSER  -> no dB: calculated using DSER
% 	OUT2(NO_OF_BLOCKS+1,1)=evaluation(4,dataref,datain,datain);
% 	OUT2(NO_OF_BLOCKS+1,2)=evaluation(4,dataref,CLEAN ,datain);
% 	OUT2(NO_OF_BLOCKS+1,3)=evaluation(4,dataref,CLEAN2,datain);
% 	OUT2(NO_OF_BLOCKS+1,4)=evaluation(4,dataref,CLEAN3,datain);

% -------------------------------------------------------------------------
% SAVE THE TIME & NUMBER OF IMFs
% -------------------------------------------------------------------------
OUT1(NO_OF_BLOCKS+1,1)=NO_IMF(1);    
OUT1(NO_OF_BLOCKS+1,2)=t_eemd;
OUT1(NO_OF_BLOCKS+1,3)=NO_IMF2(1);    
OUT1(NO_OF_BLOCKS+1,4)=toc;
end
%End of the Block Processing

% calculating average values of all evaluation measures 
% put in the last line of OUT2
OUT2(SHIFT_TIMES+2,:)=mean(OUT2(1:SHIFT_TIMES+1,:));

end

%% -------------------------------------------------------------------------
% COMPARE EEMD VS EMD VS General Filter (NO BLOCK)
% Real Data (scenario 2)
% -------------------------------------------------------------------------
% NO BLOCK: all data processed in ONE time (together)
%    T/OUT1 = no.of IMF, tEEMD, no.of IMF2, tBLOCK
%    EVAL/OUT2 = DSERref, DSEReemd, DSERemd, DSERgeneral
%    X = Reference Signals
%    S = Noisy Signals
% COMMAND: [T EVAL]=BLOCK_compare(4,X,S)
function [OUT1 OUT2]=compare4(X,S) 
% -------------------------------------------------------------------------
%INITIALIZATION
% -------------------------------------------------------------------------
tic
figure 
figures (1) = gcf;
figure 
figures (2) = gcf;

OUT1 = NaN(1, 4); 
OUT2 = NaN(1,4);

% -------------------------------------------------------------------------
% NO BLOCK PROCESSING
% -------------------------------------------------------------------------
T=1:length(S);

datain  =  S; %save the 500-data (or adjusted) block
dataref =  X;
    
% -------------------------------------------------------------------------
% EXTRACT IMFs
% -------------------------------------------------------------------------
    [t_eemd,IMF1] = rcada_eemd(datain, 0.2, 100, -1);
    NO_IMF = size(IMF1);
    
    IMF2 = rcada_emd(datain, 1, 2, -1, 10);    IMF2=IMF2';
    NO_IMF2 = size(IMF2);
    
% -------------------------------------------------------------------------
% FILTER
% -------------------------------------------------------------------------
    %1. EEMD (Proposed Method)
    [CLEAN NOISE , ~, ~] = trial_filter(3, datain,IMF1);
    %2. EMD
	[CLEAN2 NOISE2 , ~, ~] = trial_filter(3, datain,IMF2);
    %3. General Filter (using BPF FIR gaussian-windows)
    [CLEAN3 NOISE3] = trial_filter(4, datain);

% -------------------------------------------------------------------------
% PLOT
% -------------------------------------------------------------------------
%The Figures
figure(figures(1))
    subplot(211), plot(1:length(X),dataref(1:length(X)),'k'),title('REFERENCE & NOISY SIGNAL');    
        grid on; ylabel('amplitude');xlabel('samples'); legend('REFERENCE');
    subplot(212), plot(T,datain(T));    
        grid on;ylabel('amplitude');xlabel('samples');legend('NOISY');
        
figure(figures(2))
    subplot(231), plot(T,CLEAN(T)),
    title('Comparison: EEMD, EMD, General Filter (NO BLOCK)');
        grid on;ylabel('amplitude');xlabel('samples'); legend('CLEAN - EEMD');
    subplot(232), plot(T,CLEAN2(T));
        grid on;ylabel('amplitude');xlabel('samples'); legend('CLEAN - EMD');
    subplot(233), plot(T,CLEAN3(T));
        grid on;ylabel('amplitude');xlabel('samples'); legend('CLEAN - General Filter');
    subplot(234), plot(T,NOISE(T),'r');
        grid on;ylabel('amplitude');xlabel('samples');legend('NOISE - EEMD');
    subplot(235), plot(T,NOISE2(T),'r');
        grid on;ylabel('amplitude');xlabel('samples');legend('NOISE - EMD');
    subplot(236), plot(T,NOISE3(T),'r');
        grid on;ylabel('amplitude');xlabel('samples');legend('NOISE - General Filter');
% -------------------------------------------------------------------------
% EVALUATION
% -------------------------------------------------------------------------    
    % DSER(dB): calculated using DSER_var
    OUT2(1,1)=evaluation(1,dataref,datain,datain);
    OUT2(1,2)=evaluation(1,dataref,CLEAN ,datain);
    OUT2(1,3)=evaluation(1,dataref,CLEAN2,datain);
    OUT2(1,4)=evaluation(1,dataref,CLEAN3,datain);
    
   % DSER -> no dB: calculated using DSER
%     OUT2(1,1)=evaluation(4,dataref(T),datain,datain);
%     OUT2(1,2)=evaluation(4,dataref(T),CLEAN ,datain);
%     OUT2(1,3)=evaluation(4,dataref(T),CLEAN2,datain);
%     OUT2(1,4)=evaluation(4,dataref(T),CLEAN3,datain);
% -------------------------------------------------------------------------
% SAVE THE TIME & NUMBER OF IMFs
% -------------------------------------------------------------------------    
OUT1(1,1)=NO_IMF(1);    
OUT1(1,2)=t_eemd;    
OUT1(1,3)=NO_IMF2(1);
OUT1(1,4)=toc;
end
