-module(videos_get_all_handler).
-author("shree@ybrantdigital.com").

-export([init/3]).

-export([content_types_provided/2]).
-export([welcome/2]).
-export([terminate/3]).

%% Init
init(_Transport, _Req, []) ->
	{upgrade, protocol, cowboy_rest}.

%% Callbacks
content_types_provided(Req, State) ->
	{[		
		{<<"application/json">>, welcome}	
	], Req, State}.

terminate(_Reason, _Req, _State) ->
	ok.

%% API
welcome(Req, State) ->
	{Skip, SkipValue} = cowboy_req:qs_val(<<"skip">>, Req),

	% lager:info("List of Non featured videos requested"),
	% {Skip, SkipValue} = cowboy_req:qs_val(<<"skip">>, Req),
	% {Limit, LimitValue} = cowboy_req:qs_val(<<"limit">>, Req) , 
	% Url = gallyo_util:videos_get_all(binary_to_list(Limit), binary_to_list(Skip)),
 %    %Url = string:join(["http://localhost:5984/speakglobally/_design/get_videos/_view/by_id_title_thumbs_duration?descending=true&limit=", binary_to_list(Limit),"&skip=",binary_to_list(Skip)],""),	
	% {ok, "200", _, Response} = ibrowse:send_req(Url,[],get,[],[]),
	% Res = string:sub_string(Response, 1, string:len(Response) -1 ),
	% Body = list_to_binary(Res),
	% {Body, Req, State}.

	Url = string:concat("http://api.contentapi.ws/videos?channel=world_news&limit=42&format=short&skip=",binary_to_list(Skip)),
	% io:format("all videos --> ~p ~n",[Url]),
	% Url = string:concat("http://api.contentapi.ws/videos?channel=world_news&limit=42&skip=",binary_to_list(Skip)),
	{ok, "200", _, Response_mlb} = ibrowse:send_req(Url,[],get,[],[]),
	Body = list_to_binary(Response_mlb),
	{Body, Req, State}.


