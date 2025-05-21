# GameHub

GameHub is an app for playing simple 2D games made with Godot

Use the latest godot version https://godotengine.org/download/archive/

## Start

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

## Working

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

## Pull requests

Create a pull request after finishing your sprint.

Make sure to do steps 1 and 2 from the Working section.

Pull requests cannot be done using git in the Console so either use GitHub Desktop or the web via https://github.com. Make a pull request to merge your branch to `main`.

## Merge conflicts

If you get merge conflicts, open conflicting files in a text editor and remove conflicting lines, then commit the changes with a message like "Resolving merge conflict".

## How to Download Godot and Export the Project

### Step 1: Download Godot

1. Visit the [official Godot Engine website](https://godotengine.org/).
2. Navigate to the **Download** section.
3. Choose the appropriate version for your operating system (e.g., Windows, macOS, Linux).
4. Download the stable version (developed on 4.4 Stable).
5. Extract the downloaded file and run the Godot executable.

### Step 2: Open the Project

1. Launch Godot.
2. Click on **Import** and navigate to the folder containing the `project.godot` file for this game.
3. Select the file and click **Open**.

### Step 3: Install Export Templates

1. In Godot, go to **Editor** > **Manage Export Templates**.
2. Click **Download and Install** to get the latest export templates.

### Step 4: Configure your Export platforms

1. Navgate to `Project` -> `Export...` -> **Presets** `Add...` and select the platform
2. Set the output path for the exported project.
3. Click `Export Project`

### Step 5: Test the project

1. Try to run the game on your own platform:  
   Top right triangle `Run Project (F5)`
2. Try to run on local host (Database tracking probobly wont work but thats okay):  
   Top right `Remote Deploy` -> `Run in Browser`

### Step 6: Export the Web Build

1. Click **Export Project** in the Export window.
2. Choose a destination folder for the exported files.  
   Example: `../xampp/htdocs/ClarityQuest`
3. Wait for the export process to complete.
