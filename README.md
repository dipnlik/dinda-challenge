# dinda-challenge

Downloads and parses the commit history of the [braspag-rest](https://github.com/Dinda-com-br/braspag-rest) gem.

## Usage

Run the script with `script/run`.  If all goes well, output will be stored in the `exports` directory.

## Test suite

Run the test suite with `script/test`.

[simplecov](https://github.com/colszowka/simplecov) is used for coverage, you can `bundle install` if you don't have it already.

Since I could not use other gems for the project, I thought it would be nice to try not using gems for testing, so I used [minitest](https://github.com/seattlerb/minitest) instead of `rspec`.
It did the job well enough, at least for this project.
Its basic functionality can be improved using extra gems, just like `rspec-core` has a few associated gems and extensions, but I didn't have time to research that.

There are tests that actually hit the GitHub API, which isn't ideal.
I added the current rate limit to the test suite output so at least I could see if I was close to reaching it and wait for a few minutes if needed.
Fixing this would be one of the first things I'd try to do if I'd work more on this project.
