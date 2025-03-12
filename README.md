# GameHub

GameHub is an app for playing simple 2D games made with Godot

Use the latest godot version https://godotengine.org/download/archive/

# Start

1. Go to your projects folder and open up your Console to clone the repository. This will create a new `/gamehub` folder with the godot project inside.

```Console
$ git clone "https://github.com/Elektroninis-Menas/GameHub.git"
```

[!IMPORTANT]  
Do not edit anything in current branch `main`

2. Create a new branch to develop your own feature that does not conflict with others. Replace `CustomBranch` by your new feature name, like Tetris-NewShapes

```Console
$ git branch CustomBranch
$ git checkout CustomBranch
```

# Working

Update your branch with changes from remote. Simply pull changes to your main branch and merge them to your custom branch:

1. Switch to `main` and pull the latest changes from remote.

```Console
$ git switch main
$ git pull
```

2. Switch to your custom branch and update it by merging `main` into it

```Console
$ git switch CustomBranch
$ git merge
```

3. Now you can work on your new feature. After your work day, commit changes and push.

```Console
$ git add .
$ git commit -m "Write what changes you did here"
$ git push
```

# Pull requests

Create a pull request after finishing your sprint.

[!IMPORTANT]  
Make sure to do steps 1 and 2 from the Working section.

Pull requests cannot be done using git in the Console so either use GitHub Desktop or the web via https://github.com. Make a pull request to merge your branch to `main`.

# Merge conflicts

If you get merge conflicts, open conflicting files in a text editor and remove conflicting lines, then commit the changes with a message like "Resolving merge conflict".
