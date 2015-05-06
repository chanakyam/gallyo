-module(videos_pagination_handler).
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
		{<<"text/html">>, welcome}	
	], Req, State}.

terminate(_Reason, _Req, _State) ->
	ok.

%% API
welcome(Req, State) ->
	{Page, PageNumber} = cowboy_req:qs_val(<<"p">>, Req),

	Video_Url = "http://api.contentapi.ws/videos?channel=world_news&limit=1&skip=0&format=long",
	% io:format("movies url: ~p~n",[Url]),
	{ok, "200", _, Response_Video} = ibrowse:send_req(Video_Url,[],get,[],[]),
	ResponseParams_Video = jsx:decode(list_to_binary(Response_Video)),	
	[VideoParams] = proplists:get_value(<<"articles">>, ResponseParams_Video),

	Trending_Videos_Url = "http://api.contentapi.ws/videos?channel=world_news&limit=22&skip=0&format=short",
	{ok, "200", _, Response_Trending_Videos} = ibrowse:send_req(Trending_Videos_Url,[],get,[],[]),
	ResponseParams_Trending_Videos = jsx:decode(list_to_binary(Response_Trending_Videos)),	
	TrendingVideosParams = proplists:get_value(<<"articles">>, ResponseParams_Trending_Videos),

	Trending_Videos_Url1 = "http://api.contentapi.ws/videos?channel=world_news&limit=5&skip=10&format=short",
	{ok, "200", _, Response_Trending_Videos1} = ibrowse:send_req(Trending_Videos_Url1,[],get,[],[]),
	ResponseParams_Trending_Videos1 = jsx:decode(list_to_binary(Response_Trending_Videos1)),	
	TrendingVideosParams1 = proplists:get_value(<<"articles">>, ResponseParams_Trending_Videos1),	

	Popular_News_Url = "http://api.contentapi.ws/news?channel=us_politics&limit=5&skip=5&format=short",
	{ok, "200", _, Response_Popular_News} = ibrowse:send_req(Popular_News_Url,[],get,[],[]),
	ResponseParams_Popular_News = jsx:decode(list_to_binary(Response_Popular_News)),	
	PopularNewsParams = proplists:get_value(<<"articles">>, ResponseParams_Popular_News),
	
	{ok, Body} = video_paginated_page_dtl:render([{<<"videoParam">>,VideoParams},{<<"trendingvideos">>,TrendingVideosParams},{<<"trendingvideos1">>,TrendingVideosParams1},{<<"popularnews">>,PopularNewsParams}]),
	% {ok, Body} = video_paginated_page_dtl:render(),
    {Body, Req, State}.


