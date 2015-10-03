# minesweeper
My first take on Elm


## Demo

See <a href="http://sekibomazic.github.io/minesweeper/">Live demo</a>


## How to run

* `fork` this repo
* `git clone` your fork
* `cd /path/to/your/clone`
* run `elm reactor` to start the server
* point the browser to `http://localhost:8000/Minesweeper.elm`

There is also `OldMinesweeper.elm`. You can take the source code and past it on  <a href="http://elm-lang.org/try">Elm REPL</a> and run it there. This is a version without images because we can't use them in Elm REPL


## Optimization

Currently using `List` for the mine field. This was for the learning purpose.

Maybe switch to `Array` or even use some Elm matrix library


## TODO

* Enable mine flags
* Add more levels
