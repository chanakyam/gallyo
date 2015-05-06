-module(gallyo_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
	Dispatch = cowboy_router:compile([
		{'_',[
				{"/", home_page_handler, []},
                {"/termsandconditions", tnc_handler, []},
                {"/api/news/topnews", news_topnews_handler, []},     
                {"/api/news/count", news_count_by_category_handler, []},
                {"/api/news/get_all", news_get_all_by_category_handler,[]},
                {"/api/news/topnews_with_images", top_news_and_graphics_handler, []},  
                {"/api/videos/latest", videos_latest_handler , []},
                {"/api/videos/popular", videos_popular_handler ,[]},
                {"/api/videos/latest_one", videos_latest_one_handler , []},
                {"/api/videos/home_video", videos_home_video_handler, []},
                {"/api/videos/count", video_count_handler, []},
                {"/api/videos/get_all", videos_get_all_handler,[]},
                {"/videos", videos_pagination_handler, []},
                {"/p/:category", news_categories_handler, []},
                {"/v/:id", video_page_handler, []}, 

                {"/n/:id", news_page_handler, []},                      
				{"/css/[...]", cowboy_static, 
					[
                		{directory, {priv_dir, gallyo, ["public/css"]}},
                		{mimetypes, {fun mimetypes:path_to_mimes/2, default}}
            		]
            	},
                {"/fonts/[...]", cowboy_static, 
                    [
                        {directory, {priv_dir, gallyo, ["public/fonts"]}},
                        {mimetypes, {fun mimetypes:path_to_mimes/2, default}}
                    ]
                },
                
                {"/images/[...]", cowboy_static, 
                    [
                        {directory, {priv_dir, gallyo, ["public/images"]}},
                        {mimetypes, {fun mimetypes:path_to_mimes/2, default}}
                    ]
                },
                {"/js/[...]", cowboy_static, 
                    [
                        {directory, {priv_dir, gallyo, ["public/js"]}},
                        {mimetypes, {fun mimetypes:path_to_mimes/2, default}}
                    ]
                },
                {"/players/[...]", cowboy_static, 
                    [
                        {directory, {priv_dir, gallyo, ["public/players"]}},
                        {mimetypes, {fun mimetypes:path_to_mimes/2, default}}
                    ]
                },
            	% {"/", cowboy_static, 
            	% 	[
             %    		{directory, {priv_dir, gallyo, ["public"]}},
             %    		{file, "index.html"},
             %    		{mimetypes, {fun mimetypes:path_to_mimes/2, default}}
            	% 	]
            	% },
                {"/contactus", cowboy_static, 
                    [
                        {directory, {priv_dir, gallyo, ["public"]}},
                        {file, "contactus.html"},
                        {mimetypes, {fun mimetypes:path_to_mimes/2, default}}
                    ]
                }
                % {"/termsandconditions", cowboy_static, 
                %     [
                %         {directory, {priv_dir, gallyo, ["public"]}},
                %         {file, "tnc.html"},
                %         {mimetypes, {fun mimetypes:path_to_mimes/2, default}}
                %     ]
                % }
                
			 ]
		}

	]), 
    ok = application:start(lager),
    ok = application:start(crypto),
    ok = application:start(jsx),
    ok = application:start(cowlib),
    ok = application:start(ranch),
    ok = application:start(cowboy),
    ok = application:start(ibrowse),

	{ok, _} = cowboy:start_http(http,100, [{port, 9901}],[{env, [{dispatch, Dispatch}]},
                                                          {onresponse, fun error_hook_responder:respond/4}
              ]), 
    gallyo_sup:start_link().

stop(_State) ->
    ok.
