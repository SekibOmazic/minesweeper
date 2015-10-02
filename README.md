# minesweeper
My first take on Elm


## Demo

See <a href="http://rawgit.com/SekibOmazic/minesweeper/master/index.html">Live demo</a>


## How to run

* `fork` this repo
* `clone` your fork
* `elm reactor` to start the server
* point the browser to http://localhost:8000 and choose `Minesweeper.elm`

Of course you can just open index.html directly in your browser.

There is also `OldMinesweeper.elm`. You can take the source code and past it on  <a href="http://elm-lang.org/try">ELM Repl</a> and run it there.

## Optimization

Currently using `List` for the mine field. This was for the learning purpose.

The the `generateBoard` function is really slow and need improvement. Maybe I should switch to `Array` to make it faster?

## TODO

* Make board generation faster
* Enable mine flags
* Add more levels
