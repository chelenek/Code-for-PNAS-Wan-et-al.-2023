function [ Mobj ] = dizzy2matlab2(intext)
%function [ Mobj ] = dizzy2matlab( intext )
%   read in a dizzy text file, without special function calls and mass
%   action kinetics, and convert into Matlab's simulator.
%   example:
%
%   dizzy_text=fileread('dizzyfile.cmdl')
%   Mobj=dizzy2matlab(dizzy_text)
%   cs = getconfigset(Mobj);
%   set(cs, 'StopTime', 10);
%   set(cs,'SolverType','ssa')
%   [t, x,names] = sbiosimulate(Mobj,cs);
%   plot(t,x)
%
%   Rhys Adams
%   Minor edit for reaction rule definitions - Chris Helenek

%separate lines by searching for ;
lines=regexp(intext,'([^\;]+\;)','tokens');
lines=vertcat(lines{:});

%Search for lines with equal signs-those are declarations. Everything else
%is a reaction
declarations=regexp(lines,'=');
reactionlines=cellfun('isempty',declarations);
declarations=lines(not(reactionlines));
reactions=lines(reactionlines);

%Split reactions based on , or ;
%The second result is the reaction rule, i.e. A->B+C, while the third
%result is the reaction rate
reactions=regexp(reactions,'([^,|^;]+)','tokens');
reactions=vertcat(reactions{:});

reactionrule=reactions(:,1); % CHANGED FROM 2 to 1
reactionrule=vertcat(reactionrule{:});

reactionrate=reactions(:,2); % CHANGED FROM 3 to 2
reactionrate=vertcat(reactionrate{:});

%Make an Mobj based on these cell arrays
Mobj=createMobj(declarations,reactionrule,reactionrate);
