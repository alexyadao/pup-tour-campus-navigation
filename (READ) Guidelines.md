# Version Control

Format for version numbering:

v[Major].[Minor].[Patch]

Example: v1.0.0

Major Version (1) — Indicates significant updates that introduce new features, redesigns, or core structural changes to the application. These releases may not be backward compatible and often include major milestones (e.g., v1.0.0, v2.0.0).

Minor Version (0) — Represents moderate improvements, additional functionalities, or enhancements that do not drastically alter the system’s architecture (e.g., v1.1.0, v1.2.0).

Patch Version (0) — Denotes bug fixes, minor adjustments, or small optimizations made after a stable release (e.g., v1.0.1, v1.0.2).

By following this structured version control and naming convention, we'll be ensured that each updates is moderated by everyone.

# Technical Guideline #

**System Architecture**

- Flutter (Dart)
- Supabase
- PostgreSQL

**Tools & Environment**

Here are the tools and version recommended to ensure stability and compatibility for the project:

- `Github:` Use for a smooth collaboration, version control, and file consistency.
- `Flutter SDK:` Use v.3.35.7 (Stable Channel) (Optional).
- `Android Studio:` Use v2025.2.2 “Otter 2 Feature Drop” (Stable Channel).
- `Supabase Account:` Creation of a free account to manage authentication, database access and functions.
- `PUPTour Email via Google:` Creation of a dedicated project email.

> Email: PUPTour2025@gmail.com
> Password: PUPTour2025G8

## GitHub Guide (READ!) ##

All members must follow these guidelines to maintain an organized and conflict-free development environment.

### General Rules ###
- All team members must use the official project email:
- PUPTour2025@gmail.com when committing or pushing code.
- The repository will be hosted under a single GitHub account.
- All changes must include clear commit messages describing what was updated.
- Avoid directly editing files on the main branch — always create or update through a separate branch or pull request if necessary.
- Regularly pull or fetch updates before starting any new work to ensure your local files are up-to-date.

**PRACTICES**
- Use clear commit messages and upload regularly to avoid big, confusing updates.
- Always pull first, push last — this keeps everyone aligned.
- Back up major changes by pushing them to GitHub before testing.
- Double-check that your commits are made using PUPTour2025@gmail.com.
- Use the Issues tab on GitHub to track bugs, tasks, and feature ideas.
- The README.md file should always stay updated with recent progress or instructions.

## Basic Workflow ##
Basic workflow applies for all developers.\
There are 4 branches we will be working around (master, integration, frontend, backend).

**Basic Workflow is comprised of the following:**
1. Make sure you're on the right branch (The directory you'll be working on which will either be frontend or backend).
2. Pulling the files from the specific branch.
3. Updating and committing changes on your working branch (frontend or backend).

Initially you'll need to clone our repository in Android Studio, upon opening do the following:
- More Actions
- Get from Version Control
- GitHub (Make sure you're logged in)
- Choose "puptourapp" and change the directory according to your liking

**Take in mind that upon cloning, the one on your Android Studio is stored locally.**

In Android Studio's Terminal, you can check on what branch you are by entering.
```git branch```
Showing:
```
PS D:\Documents\Ivhorre Stuff\School Files\COLLEGE\1-1P\puptourapp> git branch
* master
```
To change what branch you're on, use this in terminal (Change branch to either frontend or backend).
```
git checkout (branch)
```
From there you can start working on.

There will be a lot of errors at the initial cloning of the repository, just clear and check the dependencies by entering this in terminal.
```
flutter clean
flutter pub get
```

**Now for updating and committing changes on your working branch**

Updating and committing changes is a crucial step since this may overlap on your existing work or overwrite the stable/backup directory in your GitHub Branch.

Let's say you want to update the files you have locally, enter this in terminal (remember to change the branch with either frontend or backend).
```
git pull origin (branch)
```

For committing changes, this can be done by navigating on the left side of Android Studio "Commit".\
From there checkboxes will appear, just check the changes you want or all.\
A Commit Message is required, remember to write it in a format of the README.md Instructions (Check Below).\
Commit and Push. Done.

## README.md Instructions ##

The comment or message you commit upon updating the files must also be shown here in README.md

Use this format:
```
## (Date) Update PUPTour v1.0.0 - (Your Surname)##

**Major**
- Update

**Minor**
- Update

**Patch**
- Update 1

Explanation
```

Which will be shown as

## 10.29.25 Update PUPTour v1.0.0 - Castillo ##

**Major**
- Update
  
**Minor**
- Update

**Patch**
- Update 1

Explanation

By following these GitHub guidelines, all team members can ensure that development remains synchronized, organized, and stable, avoiding overwrites or version mismatches while keeping progress transparent to the entire group.
