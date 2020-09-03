-module(ex).
% -export([fact/1]).
-compile(export_all).
-record(person, {name, age}).

fact(0) ->
	1;
fact(N) when N>0 ->
	N * fact(N-1);
fact(N) ->
	fact_negative_arg.

sum(0) ->
	0;
sum(N) when N>0 and (is_number(N)) ->
	N + sum(N-1);
sum(_) ->
	sum_negative_num.

%% Empty Node: {empty}
%% None-empty node: {node,i,left_tree,right_tree}

leaf(N) ->
	{node,N,{empty},{empty}}.

t1() ->
	{node,7,leaf(5), {node,12,leaf(10), leaf(14)}}.

size_t({empty}) ->
	0;
size_t({node,_I, LT, RT}) ->
	1+size_t(LT)+size_t(RT).

sum_t({empty}) ->
	0;
sum_t({node, I, LT, RT}) ->
	I + sum_t(LT) + sum_t(RT).

mirror_t({empty}) ->
	{empty};
mirror_t({node, I, LT, RT}) ->
	{node, I, mirror_t(RT), mirror_t(LT)}.

bump_t({empty}) ->
	{empty};
bump_t({node,I,LT,RT}) ->
	{node,I+1,bump_t(LT), bump_t(RT)}.

pre({empty}) ->
	[];
pre({node,I,LT,RT}) ->
	[I|pre(LT)++pre(RT)].

map_t(F,{empty}) ->
	{empty};
map_t(F,{node, I, LT, RT}) ->
	{node, F (I), map_t(F,LT), map_t(F,RT)}.

fold_t(F,A,{empty}) ->
	A;
fold_t(F,A,{node,I,LT,RT}) ->
	F{I, fold_t(F,A,LT), fold_t(F,A,RT)}.

p1() ->
	#person{name="Tom", Age=10}.

is_adult(#person{age=Age}) when Age >= 21 ->
	true;
is_adult(_) ->
	false.

is_adult2(P) when P#person.age >= 21 ->
	true;
is_adult2(_) ->
	false.

bday(P) ->
	P#person{age=P#person.age+1}.


