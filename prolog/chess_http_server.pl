
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(chess_api).

:- http_handler('/chess/initial', handle_initial, [method(post)]).
:- http_handler('/chess/play-move', handle_play_move, [method(post)]).
:- http_handler('/chess/position-info', handle_position_info, [method(post)]).

main :-
    http_server(http_dispatch, [port(8081)]),
    format('Chess HTTP server running on port 8081.~n', []),
    thread_get_message(stop).

% POST /chess/initial
% Returns the standard starting position.
handle_initial(_Request) :-
    (   once(chess_api:initial_fen(FEN))
    ->  reply_json_dict(_{fen: FEN})
    ;   reply_json_dict(
            _{error: "Could not create initial position"},
            [status(500)]
        )
    ).

% POST /chess/play-move
% Input:  {"fen": "...", "san": "e4"}
% Output: updated FEN, position key, status, advantage.
handle_play_move(Request) :-
    http_read_json_dict(Request, Input),
    (   get_dict(fen, Input, FEN),
        get_dict(san, Input, SAN)
    ->  (   once(chess_api:play_san_fen(
                FEN, SAN, NewFEN, PositionKey, Status, Advantage
            ))
        ->  reply_json_dict(_{
                fen: NewFEN,
                positionKey: PositionKey,
                status: Status,
                advantage: Advantage
            })
        ;   reply_json_dict(
                _{error: "Invalid position or illegal move"},
                [status(400)]
            )
        )
    ;   reply_json_dict(
            _{error: "Expected fen and san fields"},
            [status(400)]
        )
    ).

% POST /chess/position-info
% Input:  {"fen": "..."}
% Output: position key, status, advantage.
handle_position_info(Request) :-
    http_read_json_dict(Request, Input),
    (   get_dict(fen, Input, FEN)
    ->  (   once(chess_api:get_position_info(
                FEN, PositionKey, Status, Advantage
            ))
        ->  reply_json_dict(_{
                positionKey: PositionKey,
                status: Status,
                advantage: Advantage
            })
        ;   reply_json_dict(
                _{error: "Invalid FEN or position"},
                [status(400)]
            )
        )
    ;   reply_json_dict(
            _{error: "Expected fen field"},
            [status(400)]
        )
    ).
	


:- initialization(main, main).
