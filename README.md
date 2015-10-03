# minesweeper
My first take on Elm


## Demo

See <a href="http://sekibomazic.github.io/minesweeper/">Live demo</a>


## How to run

* `fork` this repo
* `clone` your fork
* `elm reactor` to start the server
* point the browser to http://localhost:8000 and choose `Minesweeper.elm`

Of course you can just open index.html directly in your browser.

There is also `OldMinesweeper.elm`. You can take the source code and past it on  <a href="http://elm-lang.org/try">ELM Repl</a> and run it there.


## Optimization

Currently using `List` for the mine field. This was for the learning purpose.

Maybe switch to `Array` or even use some Elm matrix library


## TODO

* Enable mine flags
* Add more levels
