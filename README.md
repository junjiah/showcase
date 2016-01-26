# Showcase

`showcase` is a pure client-side web app to generate portfolio-like sites
based on users' Github repositories. It fetches essential information of repos and present in a clean and minimal way. For the actual effects, scroll down to the end to check out the screenshot.

## Configure and Deploy

First, [follow those steps to install Elm](http://elm-lang.org/install).

Then generate a Github personal access token for API calls, otherwise you can only have 60 API calls in one hour, comparing to 5000 calls when using the token.

I use some silly scripts to do the configuration, which simply substitutes required information in the template file. The necessary steps are:

```bash
$ git clone https://github.com/EDFward/showcase.git
$ cd showcase
# 1. Copy the access token to a file called `github.key`.
$ vi github.key
# ... COPY ...

# 2. Copy your Github user name to `user.key`, otherwise by
# default it would be my username.
$ vi user.key
# ... WRITE YOUR NAME ...
edfward

# 3. Optionally, you can also provide a list of repository names
# which you prefer to be shown in the website. Otherwise 10 repos
# would be chosen sorted by the last time your pushed.
# The format is like ["repo_0", "repo_1", "repo_2"]
$ vi repos.key
# ... ADD PREFERRED REPOS ...
["showcase", "haskell-intro", "REAutomata",
"LearnRxImageSummary", "LearnRxUserSuggestion", "ReadKeyRSS",
"ReadKeyServer", "ReadKeyWord"]
```

Then it's is good to go!

```bash
# To run the website locally.
$ ./reactor.sh  # Checkout localhost:8000/src/Main.elm

# Or build it. All stuff will be copied to `dist` folder. Ready to deploy!
$ ./make.sh
```

## Why Elm?

I know I know, using Elm on a page without much interactivity would be an overkill. In my case, the page will only fetch some JSON at the beginning of loading, and I would say any FRP stuff would be an overkill here. Simple XMLHttpRequest and DOM manipulation will be more than sufficient.

The reason to use Elm is, of course, for learning purposes. Since recently I'm [learning Haskell](https://github.com/EDFward/haskell-intro), I just want to see how a Haskell-ish language could be used in the context of Web development. Besides some syntax differences, what really makes Elm stand out is its [architecture](https://github.com/evancz/elm-architecture-tutorial). Comparing to 'more general purpose' Haskell, Elm seems to be specialized in *model-update-view* paradigm (much like what React is to Javascript). At first the pattern feels unwieldy, I often scratched my head and wondered what is `Effects`, what is `Task` and what is `Effects.task`. In this sense, Elm acts like yet another *framework*, such as React or Rx. But on the other hand, such reactivity doesn't come from third-party libraries, instead it's from the language itself. `Task` and more importantly, `Signal` are all from Elm's core library, which makes it possible that in the future other people could create another *architecture* and provide better programming experiences. 

I look forward to it, but personally may not use Elm for other projects any more. It still...lacks some thing. For me, the development process is not as fun as I anticipated.

## Screenshot

![screenshot](http://i.imgur.com/NdISIz6.png)
