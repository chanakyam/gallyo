-module(news_categories_handler).
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
	{[{Name,Value}], Req2} = cowboy_req:bindings(Req),
	{Page, PageNumber} = cowboy_req:qs_val(<<"page">>, Req),
	SkipItems = (list_to_integer(binary_to_list(Page))-1) * 15,
	Url = case binary_to_list(Value) of 
		"World" ->
			%Category = "US",
			string:concat("http://api.contentapi.ws/news?channel=us_world&limit=40&format=short&skip=",integer_to_list(SkipItems));
		"US" ->
			%Category = "US",
			string:concat("http://api.contentapi.ws/news?channel=us_domestic&limit=40&format=short&skip=",integer_to_list(SkipItems));
			
		"Politics" ->
			%Category = "Politics",
			string:concat("http://api.contentapi.ws/news?channel=us_politics&limit=40&format=short&skip=",integer_to_list(SkipItems));
			
		"Entertainment" ->
			%Category = "Entertainment",
			string:concat("http://api.contentapi.ws/news?channel=us_entertainment&limit=40&format=short&skip=",integer_to_list(SkipItems));
		
		"Markets" ->
			%Category = "Entertainment",
			string:concat("http://api.contentapi.ws/news?channel=us_markets&limit=40&format=short&skip=",integer_to_list(SkipItems));
		
		"Money" ->
			%Category = "Entertainment",
			string:concat("http://api.contentapi.ws/news?channel=us_money&limit=40&format=short&skip=",integer_to_list(SkipItems));
		_ ->

			%Category = "None",
			lager:info("#########################None")

	end,

	% for videos

	Video_Url = case binary_to_list(Value) of 
		"World" ->
			%Category = "US",
			"http://api.contentapi.ws/videos?channel=world_news&limit=1&skip=1&format=long";
		"US" ->
			%Category = "US",
			"http://api.contentapi.ws/videos?channel=world_news&limit=1&skip=2&format=long";
			
		"Politics" ->
			%Category = "Politics",
			"http://api.contentapi.ws/videos?channel=world_news&limit=1&skip=3&format=long";
			
		"Entertainment" ->
			%Category = "Entertainment",
			"http://api.contentapi.ws/videos?channel=world_news&limit=1&skip=4&format=long";
		
		"Markets" ->
			%Category = "Entertainment",
			"http://api.contentapi.ws/videos?channel=world_news&limit=1&skip=5&format=long";
		
		"Money" ->
			%Category = "Entertainment",
			"http://api.contentapi.ws/videos?channel=world_news&limit=1&skip=6&format=long";
		_ ->

			%Category = "None",
			lager:info("#########################None")

	end,

	{ok, "200", _, Response} = ibrowse:send_req(Url,[],get,[],[]),
	ResponseParams = jsx:decode(list_to_binary(Response)),	
	ParamsAllNews = proplists:get_value(<<"articles">>, ResponseParams),

	% Video_Url = "http://api.contentapi.ws/videos?channel=world_news&limit=1&skip=0&format=long",
	% io:format("movies url: ~p~n",[Url]),
	{ok, "200", _, Response_Video} = ibrowse:send_req(Video_Url,[],get,[],[]),
	ResponseParams_Video = jsx:decode(list_to_binary(Response_Video)),	
	[VideoParams] = proplists:get_value(<<"articles">>, ResponseParams_Video),

	Trending_Videos_Url1 = "http://api.contentapi.ws/videos?channel=world_news&limit=5&skip=10&format=short",
	{ok, "200", _, Response_Trending_Videos1} = ibrowse:send_req(Trending_Videos_Url1,[],get,[],[]),
	ResponseParams_Trending_Videos1 = jsx:decode(list_to_binary(Response_Trending_Videos1)),	
	TrendingVideosParams1 = proplists:get_value(<<"articles">>, ResponseParams_Trending_Videos1),	

	Popular_News_Url = "http://api.contentapi.ws/news?channel=us_politics&limit=5&skip=5&format=short",
	{ok, "200", _, Response_Popular_News} = ibrowse:send_req(Popular_News_Url,[],get,[],[]),
	ResponseParams_Popular_News = jsx:decode(list_to_binary(Response_Popular_News)),	
	PopularNewsParams = proplists:get_value(<<"articles">>, ResponseParams_Popular_News),
	
	{ok, Body} = news_categories_page_dtl:render([{<<"titles">>, ParamsAllNews},{<<"videoParam">>,VideoParams}, {<<"category">>, binary_to_list(Value) },{<<"trendingvideos1">>,TrendingVideosParams1},{<<"popularnews">>,PopularNewsParams}]),
    {Body, Req2, State}.
    


