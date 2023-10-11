% SimpDiz
% Simplify Dizzy script to be able to run in MATLAB
% Created by Chris Helenek, 2022

function simptxt = SimpDiz(inpt,dsym)

% Read file
rawtxt = fileread(inpt);

% Check if there is a model name, and if so, delete it
mdl = regexp(rawtxt,'#');
if isempty(mdl)
elseif mdl(1) == 1
    rawtxt = delrow(rawtxt,1);
end

% Delete comments
ii = 1;
while ii<=length(rawtxt)
    if rawtxt(ii) == '/' && rawtxt(ii+1) == '/' % Single line comment
        rawtxt = delrow(rawtxt,ii);
    end
    if rawtxt(ii) == '/' && rawtxt(ii+1) == '*' % Multi line comment
        rawtxt = delsec(rawtxt,ii);
    end
    ii = ii + 1;
end

% // Loops // 
% Search for keyword "loop"
loop_indx = regexp(rawtxt,'loop');
ctr = 1; loop_lines = cell(1,length(loop_indx));
if ~isempty(loop_indx)
    for ii = loop_indx
        % Make new lines based on the loop structure
        [loop_lines{ctr},del_indx{ctr}] = get_loop_lines(rawtxt,ii);
        ctr = ctr + 1;
    end
    % Delete the loop sections from the rawtext
    for ii = ctr-1:-1:1
        rawtxt(del_indx{ii}(1):del_indx{ii}(2)) = '';
    end
end


% Separate based into lines
lines=regexp(rawtxt,'([^\;]+\;)','tokens');
lines=vertcat(lines{:});

% Add the loop reactions
emplinflg = false;
if isempty(lines) % If empty, create
    lines = cell(1);
    emplinflg = true;
end
for ii = 1:length(loop_lines)
    for z = 1:length(loop_lines{ii})
        lines{end+1} = loop_lines{ii}{z}; % Adding each line of loop structure
    end
end
if emplinflg % Delete first empty entry
    lines(1) = '';
    lines = lines';
end

% Initialize degradation symbols
degsym = strcat(dsym,'1'); degflg = true;
grtsym = strcat(dsym,'2'); grtflg = true;

% Loop through lines
for ii = 1:length(lines)

    % // Degradations and Growths // % 

    % Check if there is an arrow '->'
    arrowpos = regexp(lines{ii},'->','once');
    if ~isempty(arrowpos)
        % Find commas
        commas = regexp(lines{ii},',');
        % Delete reaction names
        if length(commas) == 2 % Reaction name
            lines{ii}(1:commas(1)) = [];
            commas(2) = commas(2) - commas(1);
            arrowpos = arrowpos - commas(1);
            commas(1) = 1; 
        elseif length(commas) == 1 % No Reaction name
            commas(2) = 1;
            commas = flip(commas);
        end
        % Extract sections between commas and arrows
        firstsec = lines{ii}(commas(1)+1:arrowpos-1);
        secondsec = lines{ii}(arrowpos+2:commas(2)-1);
        % If all spaces, add dummy variable
        if all(secondsec == ' ') % Deg sym
            lines{ii} = insertAfter(lines{ii},'->', degsym);
            if degflg % First time it is added
                lines{end+1} = [newline,degsym,'=0;'];
                %lines{end+1} = strcat(degsym,'+',degsym,'->',degsym,',1000');
                degflg = false;
            end
        end
        if all(firstsec == ' ') % Grt sym
            lines{ii} = insertBefore(lines{ii},'->',grtsym);
            lines{ii} = insertAfter(lines{ii},'->',strcat(grtsym,'+'));
            if grtflg % First time it is added
                lines{end+1} = [newline,grtsym,'=1;'];
                grtflg = false;
            end
        end
    end

    % // Logs // %
    lns = regexp(lines{ii},'ln','once');
    if ~isempty(lns)
        lines{ii} = strrep(lines{ii},'ln','log');
    end

    % Add newline at beginning
    lines{ii} = [newline,lines{ii}];
end

% Create out-text

simptxt = strcat(lines{:});

% Auxiliary functions

% Delete a single line comment
    function otxt = delrow(itxt,indx)
        jj = indx;
        while jj <= length(itxt) % Incremenet
            if itxt(jj) == newline % If new line...
                break % Leave loop
            end
            itxt(jj) = []; % Otherwise, delete
        end
        otxt = itxt;
    end

% Delete a multi line comment
    function otxt = delsec(itxt,indx)
        jj = indx;
        while jj <= length(itxt) % Increment
            if itxt(jj) == '*' && itxt(jj+1) == '/' % If end of multi-line comment...
                itxt(jj+1)=[]; itxt(jj)=[]; % Leave loop
                break
            end
            itxt(jj) = []; % Otherwise, delete
        end
        otxt = itxt;
    end

% Get loop structures
    function [newlines,del_indx] = get_loop_lines(itxt,indx)

        % Searches
        loop_commas = regexp(itxt,',');
        loop_parenth = regexp(itxt,'[()]');
        loop_curly = regexp(itxt,'[{}]'); 

        % Take the commas and parenthesis only in the region
        loop_commas = loop_commas(loop_commas>indx);
        loop_parenth = loop_parenth(loop_parenth>indx);
        loop_curly = loop_curly(loop_curly>indx);

        % Extracting information
        loop_char = itxt(loop_parenth(1)+1:loop_commas(1)-1); % Looping character
        loop_start = itxt(loop_commas(1)+1:loop_commas(2)-1); % Loop start
        loop_end = itxt(loop_commas(2)+1:loop_parenth(2)-1); % Loop end
        loop_text = itxt(loop_curly(1)+1:loop_curly(2)-1); % Loop text
        % Get rid of spaces
        loop_char = strtrim(loop_char); loop_start = strtrim(loop_start); loop_end = strtrim(loop_end);


        % Separate into lines
        rawlooplines=regexp(loop_text,'([^\;]+\;)','tokens');
        rawlooplines=vertcat(rawlooplines{:});

        % Loop through lines
        loop_ctr = 1; newlines = cell(1,1);
        for n = 1:length(rawlooplines) % For each line...
            for c = loop_start:loop_end % For each loop...
                newlines{loop_ctr} = rawlooplines{n}; % Copy line
                newlines{loop_ctr} = strrep(newlines{loop_ctr},loop_char,c); % Replace loop character
                remchars = regexp(newlines{loop_ctr},'[\[\]"]'); % Characters to delete
                newlines{loop_ctr}(remchars)=''; % Delete characters
                loop_ctr = loop_ctr + 1;
            end

        end

        % Output the indexes to delete
        del_indx = [indx,loop_curly(2)];
        
    end

end