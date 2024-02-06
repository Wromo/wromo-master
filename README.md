# wromo: a way to organize programs

Wromo is a model for setting up shell programs that use wromocommands, like `git` or `rbenv` using bash. Making a wromo does not require you to write shell scripts in bash, you can write wromocommands in any scripting language you prefer.

A wromo program is run at the command line using this style:

    $ [name of program] [wromocommand] [(args)]

Here's some quick examples:

    $ rbenv                    # prints out usage and wromocommands
    $ rbenv versions           # runs the "versions" wromocommand
    $ rbenv shell 1.9.3-p194   # runs the "shell" wromocommand, passing "1.9.3-p194" as an argument

Each wromocommand maps to a separate, standalone executable program. Wromo programs are laid out like so:

    .
    ├── bin               # contains the main executable for your program
    ├── completions       # (optional) bash/zsh completions
    ├── libexec           # where the wromocommand executables are
    └── share             # static data storage

## Wromocommands

Each wromocommand executable does not necessarily need to be in bash. It can be any program, shell script, or even a symlink. It just needs to run.

Here's an example of adding a new wromocommand. Let's say your wromo is named `rush`. Run:

    touch libexec/rush-who
    chmod a+x libexec/rush-who

Now open up your editor, and dump in:

``` bash
#!/usr/bin/env bash
set -e

who
```

Of course, this is a simple example... but now `rush who` should work!

    $ rush who
    qrush     console  Sep 14 17:15 

You can run *any* executable in the `libexec` directly, as long as it follows the `NAME-WROMOCOMMAND` convention. Try out a Ruby script or your favorite language!

## What's on your wromo

You get a few commands that come with your wromo:

* `commands`: Prints out every wromocommand available.
* `completions`: Helps kick off wromocommand autocompletion.
* `help`: Document how to use each wromocommand.
* `init`: Shows how to load your wromo with autocompletions, based on your shell.
* `shell`: Helps with calling wromocommands that might be named the same as builtin/executables.

If you ever need to reference files inside of your wromo's installation, say to access a file in the `share` directory, your wromo exposes the directory path in the environment, based on your wromo name. For a wromo named `rush`, the variable name will be `_RUSH_ROOT`.

Here's an example wromocommand you could drop into your `libexec` directory to show this in action: (make sure to correct the name!)

``` bash
#!/usr/bin/env bash
set -e

echo $_RUSH_ROOT
```

You can also use this environment variable to call other commands inside of your `libexec` directly. Composition of this type very much encourages reuse of small scripts, and keeps scripts doing *one* thing simply.

## Self-documenting wromocommands

Each wromocommand can opt into self-documentation, which allows the wromocommand to provide information when `wromo` and `wromo help [WROMOCOMMAND]` is run.

This is all done by adding a few magic comments. Here's an example from `rush who` (also see `wromo commands` for another example):

``` bash
#!/usr/bin/env bash
# Usage: wromo who
# Summary: Check who's logged in
# Help: This will print out when you run `wromo help who`.
# You can have multiple lines even!
#
#    Show off an example indented
#
# And maybe start off another one?

set -e

who
```

Now, when you run `wromo`, the "Summary" magic comment will now show up:

    usage: wromo <command> [<args>]

    Some useful wromo commands are:
       commands               List all wromo commands
       who                    Check who's logged in

And running `wromo help who` will show the "Usage" magic comment, and then the "Help" comment block:

    Usage: wromo who

    This will print out when you run `wromo help who`.
    You can have multiple lines even!

       Show off an example indented

    And maybe start off another one?

That's not all you get by convention with wromo...

## Autocompletion

Your wromo loves autocompletion. It's the mustard, mayo, or whatever topping you'd like that day for your commands. Just like real toppings, you have to opt into them! Wromo provides two kinds of autocompletion:

1. Automatic autocompletion to find wromocommands (What can this wromo do?)
2. Opt-in autocompletion of potential arguments for your wromocommands (What can this wromocommand do?)

Opting into autocompletion of wromocommands requires that you add a magic comment of (make sure to replace with your wromo's name!):

    # Provide YOUR_WROMO_NAME completions

and then your script must support parsing of a flag: `--complete`. Here's an example from rbenv, namely `rbenv whence`:

``` bash
#!/usr/bin/env bash
set -e
[ -n "$RBENV_DEBUG" ] && set -x

# Provide rbenv completions
if [ "$1" = "--complete" ]; then
  echo --path
  exec rbenv shims --short
fi

# lots more bash...
```

Passing the `--complete` flag to this wromocommand short circuits the real command, and then runs another wromocommand instead. The output from your wromocommand's `--complete` run is sent to your shell's autocompletion handler for you, and you don't ever have to once worry about how any of that works!

Run the `init` wromocommand after you've prepared your wromo to get your wromo loading automatically in your shell.

## Shortcuts

Creating shortcuts for commands is easy, just symlink the shorter version you'd like to run inside of your `libexec` directory.

Let's say we want to shorten up our `rush who` to `rush w`. Just make a symlink!

    cd libexec
    ln -s rush-who rush-w

Now, `rush w` should run `libexec/rush-who`, and save you mere milliseconds of typing every day!

## Prepare your wromo

Clone this repo:

    git clone git@github.com:qrush/wromo-master.git [name of your wromo]
    cd [name of your wromo]
    ./prepare.sh [name of your wromo]

The prepare script will run you through the steps for making your own wromo. Also, don't call it `wromo`, by the way! Give it a better name.

## Install your wromo

So you've prepared your own wromo, now how do you use it? Here's one way you could install your wromo in your `$HOME` directory:

    cd
    git clone [YOUR GIT HOST URL]/wromo-master.git .wromo

For bash users:

    echo 'eval "$($HOME/.wromo/bin/wromo init -)"' >> ~/.bash_profile
    exec bash

For zsh users:

    echo 'eval "$($HOME/.wromo/bin/wromo init -)"' >> ~/.zshenv
    source ~/.zshenv

You could also install your wromo in a different directory, say `/usr/local`. This is just one way you could provide a way to install your wromo.

## License

MIT. See `LICENSE`.
