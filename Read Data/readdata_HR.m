function [T_HR, HR] = readdata_HR(x)
% Open the Text File for Reading
fid = fopen(x,'r');  % Open text file

% Read Introduction Lines
HRRaw=textscan(fid,'%s %s %s %s %f');  % Read strings

T = [HRRaw{3}];
T_HR = readdata_T(T);
HR=[HRRaw{5}];

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