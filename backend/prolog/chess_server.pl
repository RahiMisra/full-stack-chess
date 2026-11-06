
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
    json_write_dict(user_output, Response, [width(0), null(null)]),
    nl,
    flush_output(user_output).

% Handle incoming requests.
handle_request(Request, Response) :-
    get_dict(action, Request, Action),

    (   Action == "play_san"
    ->  get_dict(fen, Request, Fen),
        get_dict(san, Request, San),
        (   chess_api:play_san_fen(
                Fen, San,
                NewFen, PositionKey, Status, Advantage,
                MoveType, SideToMove, CastlingRights, EnPassant
            )
        ->  Response = _{
                success: true,
                newFen: NewFen,
                positionKey: PositionKey,
                status: Status,
                advantage: Advantage,
                moveType: MoveType,
                sideToMove: SideToMove,
                castlingRights: CastlingRights,
                enPassantTarget: EnPassant
            }
        ;   Response = _{
                success: false,
                error: "Invalid position or move"
            }
        )

    ;   Action == "play_coordinates"
    ->  get_dict(fen, Request, Fen),
        get_dict(from, Request, From),
        get_dict(to, Request, To),
        get_dict(promotion, Request, Promotion),
        (   chess_api:play_coordinates_fen(
                Fen, From, To, Promotion,
                NewFen, PositionKey, Status, Advantage,
                SAN, MoveType, SideToMove, CastlingRights, EnPassant
            )
        ->  Response = _{
                success: true,
                newFen: NewFen,
                positionKey: PositionKey,
                status: Status,
                advantage: Advantage,
                san: SAN,
                moveType: MoveType,
                sideToMove: SideToMove,
                castlingRights: CastlingRights,
                enPassantTarget: EnPassant
            }
        ;   Response = _{
                success: false,
                error: "Invalid position or move"
            }
        )

    ;   Action == "get_position_info"
    ->  get_dict(fen, Request, Fen),
        (   chess_api:get_position_info(
                Fen, PositionKey, Status, Advantage,
                SideToMove, CastlingRights, EnPassant
            )
        ->  Response = _{
                success: true,
                positionKey: PositionKey,
                status: Status,
                advantage: Advantage,
                sideToMove: SideToMove,
                castlingRights: CastlingRights,
                enPassantTarget: EnPassant
            }
        ;   Response = _{
                success: false,
                error: "Invalid FEN or position"
            }
        )

    ;   Action == "get_legal_moves"
    ->  get_dict(fen, Request, Fen),
        get_dict(square, Request, Square),
        (   chess_api:get_piece_legal_moves(
                Fen, Square, LegalMoves
            )
        ->  Response = _{
                success: true,
                moves: LegalMoves
            }
        ;   Response = _{
                success: false,
                error: "Invalid position or square"
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
