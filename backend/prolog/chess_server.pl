:- use_module(library(http/json)).

% Load chess_api.pl from the same directory as this script.
:- prolog_load_context(directory, PrologDir),
   directory_file_path(PrologDir, 'chess_api.pl', ApiPath),
   use_module(ApiPath).

% Keep reading requests until stdin reaches EOF.
main :-
    repeat,
    read_line_to_string(user_input, Line),
    (   Line == end_of_file
    ->  !
    ;   Line == ""
    ->  fail
    ;   process_line(Line),
        fail
    ).

% Parse and handle one JSON request.
process_line(Line) :-
    catch(
        (   atom_string(JsonAtom, Line),
            atom_json_dict(JsonAtom, Request, []),
            handle_request(Request, Response)
        ),
        Error,
        error_response(Error, Response)
    ),
    json_write_dict(user_output, Response, [width(0)]),
    nl,
    flush_output(user_output).

% Handle a request to apply a SAN move.
handle_request(Request, Response) :-
    get_dict(action, Request, Action),
    (   Action == "play_move"
    ->  get_dict(fen, Request, Fen),
        get_dict(san, Request, San),
        (   chess_api:play_san_fen(
                Fen, San, NewFen, PositionKey, Status, Advantage
            )
        ->  Response = _{
                success: true,
                newFen: NewFen,
                positionKey: PositionKey,
                status: Status,
                advantage: Advantage
            }
        ;   Response = _{
                success: false,
                error: "Invalid position or move"
            }
        )
    ;   Response = _{
            success: false,
            error: "Unknown action"
        }
    ).

% Convert exceptions into JSON instead of terminating the process.
error_response(Error, Response) :-
    message_to_string(Error, Message),
    Response = _{
        success: false,
        error: Message
    }.

:- initialization(main, main).