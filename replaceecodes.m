function [newecodes, newetimes] = replaceecodes(ecodes,etimes,whenspikes,whentrigs,whatcodes,whichclus)
if nargin == 5
whichclus = 1;
end
global triggertimes spike2times clustercodes
whentrigs = round(triggertimes.*1e3);
striggertimes = whentrigs(1:2:end); %start trigger times: remove end triggers
whenspikes = round(spike2times.*1e3);
whatcodes = clustercodes;
%% recast in terms of REX times
% find first good trial
a = 0;
foundit = 0;
    trialstart = find(ecodes == 1001);
	lastevent = length(ecodes);
	trialend = [trialstart(2:end);lastevent];
    starttrigs = zeros(length(trialstart),1);
    endtrigs = zeros(length(trialstart),1);
% get start and end times for each trial
    for co = 1:length(trialstart)
        starttrigs(co) = etimes(trialstart(co))-1;
        nextcodes = ecodes(trialstart(co):trialend(co));
        nexttimes = etimes(trialstart(co):trialend(co));
        d = find(nextcodes == 1502,1);
        if ~isempty(d)
            endtrigs(co) = nexttimes(d);
        else
        d = find(nextcodes == 1030,1);
        if ~isempty(d)
            endtrigs(co) = nexttimes(d);
        else
            endtrigs(co) = NaN;
        end
        end
    end
while ~foundit
    a = a+1;
    nextcodes = ecodes(trialstart(a):trialend(a));
    if ~sum(nextcodes == 17385)
        foundit = 1;
    end
end
% align
int1 = endtrigs-starttrigs;
int3 = int1(a);
triglengths = round(diff(triggertimes(1:2:end)).*1e3);
b = find(triglengths>=(int3-1) & triglengths<=(int3+1),1);
if isempty(b)
        errmess= sprintf('WARNING: Unable to find a pair of triggers that matches the length of the first trial.\n');
        disp(errmess);
end
% align = starttrigs(1:a);
% align = (align-align(end))./1000;
% align = triggertimes(b)+align(1);
% align = round(align.*1000);
% c = find(whentrigs==align,1);
firsttrig = whentrigs(b);
firststart = starttrigs(a);
offset =firststart-firsttrig;
if isempty(offset)
    offset = firststart-whentrigs(1);
end
% check if alignement is good 
    % there's a gradual offset! different clock times between computers?
    % See striggertimes-(etimes(ecodes == 1001)-offset)
    if max(diff(striggertimes)-diff(etimes(ecodes == 1001)-offset))>1
        %try different alignement
        striggertimes = whentrigs(2:2:end);
        if max(diff(striggertimes)-diff(etimes(ecodes == 1001)-offset))<=1
            %keep alternative alignement
            fprintf('missing trigger, adjusting alignement. CODE TO BE COMPLETED');
            triglengths = round(diff(triggertimes(2:2:end)).*1e3);
            b = find(triglengths>=(int3-1) & triglengths<=(int3+1),1);
            if isempty(b)
                    errmess= sprintf('WARNING: Unable to find a pair of triggers that matches the length of the first trial.\n');
                    disp(errmess);
            end
            firsttrig = whentrigs(b);
            firststart = starttrigs(a);
            offset =firststart-firsttrig;
            if isempty(offset)
                offset = firststart-whentrigs(1);
            end
        end
    end
if 1
    fprintf('There are %d triggers\n',length(whentrigs));
    fprintf('There are %d start times\n',sum(ecodes == 1001));
    figure(99);clf;
    %offwhen = striggertimes+offset;
    plot(striggertimes,striggertimes.^0,'rd','MarkerSize',20); % red diamonds: spike2 triggers
    hold on;
    plot(etimes(ecodes == 1001)-offset,(etimes(ecodes==1001)-offset).^0,'ko','MarkerSize',20); % black circles rex start codes
    ticks = unique([etimes(ecodes == 1001)-offset; striggertimes]);
    set(gca,'XTick',ticks)
    set(gca,'XTickLabel',sprintf('%3.0f|',ticks))
    legend('Spk2 trigs','REX start codes');
end
% while ~(length(whentrigs)==sum(ecodes == 1001))
%     whentrigs(1) = [];
%     offset = firststart-whentrigs(1);
% end

%if (whentrigs+offset)==etimes(ecodes == 1001)
whenspikes = whenspikes+offset;

%% Isolate cluster
whenspikes = whenspikes(whatcodes == whichclus);

%% Remove old spikes and references to analog
newecodes = ecodes;
newetimes = etimes;

newetimes(newecodes == 610) = [];
newecodes(newecodes == 610) = [];
 
 atimes = newetimes(newecodes == -112);
 newetimes(newecodes == -112) = [];
 newecodes(newecodes == -112) = [];

%% Add new spikes and sort
addecodes = 610.*ones(length(whenspikes),1);
newecodes = [ newecodes; addecodes];
newetimes = [ newetimes; whenspikes];

[newetimes,ind] = sort(newetimes);
newecodes = newecodes(ind);

addacodes = -112.*ones(length(atimes),1);
newetimes = [newetimes; atimes];
newecodes = [newecodes; addacodes];
end
%end

