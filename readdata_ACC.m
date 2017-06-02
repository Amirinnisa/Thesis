% clear all;
function [T_ACC, ACC]=readdata_ACC(x)
% Open the Text File for Reading
fid = fopen(x,'r');  % Open text file

% Read Introduction Lines
% Read strings
ACCRaw=textscan(fid,'%s %s %s %s %s %s %f %s %s %f %s %s %f');

T = [ACCRaw{3}];
T_ACC = readdata_T(T);
ACC = [ACCRaw{7} ACCRaw{10} ACCRaw{13}];

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
% clf
% figure
% subplot(211)
% plot(ACC)
% xlabel('Sampling')
% ylabel('bytes')
% legend('X','Y','Z')
% 
% %%
% % figure
% subplot(212)
% plot(ACC/4096)
% xlabel('Sampling')
% ylabel('after divided by 4096 (g)')
% legend('X','Y','Z')
