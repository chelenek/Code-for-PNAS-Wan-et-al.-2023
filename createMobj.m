function [ Mobj ] = createMobj( declarations,reactionrule,reactionrate)
%function [ Mobj ] = createMobj( declarations,reactionrule,reactionrate)
%   declarations-a cell array of text strings. Should be of the form a=##.
%   This should include starting concentrations, as well as any reaction
%   rates.
%   reactionrule- a cell array of text strings. Should be of the form
%   X->X+X
%   reactionrate- a cell array of text strings describing the reaction
%   rates of their corresponding rules, may be numeric or symbolic
%   Example:
%
%   declarations={'C=1'};
%   reactionrule={'C->C+C'};
%   reactionrate={'0.1'};
%   Mobj=createMobj(declarations,reactionrule,reactionrate);
%   cs = getconfigset(Mobj);
%   set(cs, 'StopTime', 20);
%   set(cs,'SolverType','ssa')
%   [t, x,names] = sbiosimulate(Mobj,cs);
%   plot(t,x)
%
% Rhys Adams

reactionrule=regexprep(reactionrule,'+',' + ');
reactionrule=regexprep(reactionrule,'-',' -');
reactionrule=regexprep(reactionrule,'>','> ');

for i=1:length(declarations)
    eval([declarations{i},';']);
end

Mobj = sbiomodel('SbioModel1');
addcompartment(Mobj, 'contents');

Robj=cell(length(reactionrule),1);
Kobj=Robj;
Pobj=Robj;
for i=1:length(reactionrule)
    Robj{i} = addreaction(Mobj, reactionrule{i});
    Kobj{i} = addkineticlaw(Robj{i},'MassAction');
    Pobj{i} = addparameter(Kobj{i}, reactionrate{i},eval(reactionrate{i}));
    set(Kobj{i}, 'ParameterVariableNames', reactionrate{i});
end

for i=1:length(Mobj.species)
    Sobj1 = sbioselect(Mobj, 'Type', 'species', 'Name', Mobj.species(i).Name);
    set(Sobj1, 'InitialAmount', eval(Mobj.species(i).Name));
end


end

