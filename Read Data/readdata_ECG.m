% clear all;
function [T_ECG, ECG] = readdata_ECG(x)
% Open the Text File for Reading
fid = fopen(x,'r');  % Open text file

% Read Introduction Lines
ECGRaw=textscan(fid,'%s %s %s %s %f');  % Read strings

T=[ECGRaw{3}];
T_ECG = readdata_T(T);
ECG=[ECGRaw{5}];

fclose(fid);
end
%% Open the Text File for Reading
% function [hh, mm, ss]=readdata_T(Time)
function tfinal=readdata_T(Time)
for i=1:length(Time),
time(i,:) = textscan(Time{i}, '%f %f %f', 'delimiter', ':');
end
hh=[time{:,1}]';
mm=[time{:,2}]';
ss=[time{:,3}]';

t=(hh*3600+mm*60+ss)-(hh(1)*3600+mm(1)*60+ss(1));
tfinal = normalised(t);
% fclose(fid);
end
%%
function tfinal = normalised(t)
lt=length(t);
tfinal=zeros(lt,1);
    for i=t(1):t(end);
    idx=find(t==i);
      if (length(idx)==1)
          tfinal(idx(1),1)=i;
      else if (length(idx)>1)
          lx=length(idx); 
          tfin(1) = i;
          for n=2:lx
            tfin(n) = i+((n-1)/lx);
          end
          tfinal(idx(1):idx(end),1)=tfin(:)';
          clear tfin;
          end
      end
    end
end
%%
% figure 
% subplot(211)
% plot(ECG)
% xlabel('Sampling')
% ylabel('bytes')
% % legend('')
% 
% subplot(212)
% plot(ECG/4096)
% xlabel('Sampling')
% ylabel('after divided by 4096')
% legend('X','Y','Z')

