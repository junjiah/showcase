# Showcase

`showcase` is a pure client-side web app to generate portfolio-like sites
based on users' Github repositories. It fetches essential information of repos and present in a clean and minimal way. For the actual effects, scroll down to the end to check out the screenshot.

## First try on Elm

[TODO]

## Configure and Deploy

First, [follow those steps to install Elm](http://elm-lang.org/install).

Then generate a Github personal access token for API calls, otherwise we can only have 60 API calls in one hour, comparing to 5000 calls hourly when using the token.

I use some silly scripts to do the configuration, which basically just substitutes required information to the template file. The necessary steps are:

```bash
$ cd showcase
# 1. Copy the access token to a file called `github.key`.
$ vi github.key
# ... COPY ...

# 2. Copy your Github user name to `user.key`, otherwise the 
# default would be my username. 
$ vi user.key
# ... WRITE YOUR NAME ...

# 3. Optionally, you can also provide a list of repository names
# which you prefer to be shown in the website. Otherwise `showcase`
# will choose 10 repos sorted by the last time your pushed.
# The format is like ["repo_0", "repo_1", "repo_2"]
$ vi repos.key
# ... ADD PREFERRED REPOS ...
```

Then `showcase` is good to go!

```bash
# To run the web site locally.
# Go to localhost:8000/src/Main.elm
$ ./reactor.sh

# Or build the web site. 
# All stuff will be copied to `dist` folder. Ready to deploy!
$ ./make.sh
```

## Screenshot

![screenshot](http://i.imgur.com/NdISIz6.png)
