{
  aliases = {
    ## Aliases that are not as commonly used or are more complex

    ### Diff, diff stat, diff cached
    d = "diff";
    ds = "diff --stat";
    dc = "diff --cached";

    ## History / Listing
    ### One-line log
    l = "log --pretty=format:\"%C(yellow)%h\\ %ad%Cred%d\\ %Creset%s%Cblue\\ [%cn]\" --decorate --date=short";
    ### Pretty formatted git log
    ll = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate --numstat";
    lg = "log --pretty=format:\"%C(magenta)%h%Creset -%C(red)%d%Creset %s %C(dim green)(%cr) [%an]\" --abbrev-commit -30";

    ### List aliases
    la = "!git config -l | grep alias | cut -c 7-";
    ### List branches sorted by last modified
    lb = "!git for-each-ref --sort='-authordate' --format='%(authordate)%09%(objectname:short)%09%(refname)' refs/heads | sed -e 's-refs/heads/--'";
    ### List branches and their tracked remotes
    lbr = "branch -vv";
    ### Display current branch
    b = "rev-parse --abbrev-ref HEAD";
    ### Aside from providing one-line logs, it also shows the branching in/out
    hist = "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short";
  };

  shellAliases = {
    # Git aliases
    g = "git";
    ga = "git add";
    gaa = "git add --all";

    gb = "git branch";
    gbd = "git branch -d";
    gbD = "git branch -D";

    gbl = "git blame -b -w";

    gc = "git commit -v";
    gcm = "git commit -v -m";
    gca = "git commit -v --amend";
    gcam = "git commit -v --amend -m";

    gco = "git checkout";
    gcob = "git checkout -b";

    gd = "git diff";

    gf = "git fetch";
    gfo = "git fetch origin";
    gfu = "git fetch upstream";

    gl = "git log";

    gm = "git merge";

    gP = "git pull --rebase";
    gPo = "git pull --rebase origin";
    gPm = "git pull --no-rebase";
    gPmo = "git pull --no-rebase origin";

    gp = "git push";

    grb = "git rebase";
    grba = "git rebase - -abort";
    grbc = "git rebase - -continue";

    gr = "git remote -v";
    gra = "git remote add";

    gR = "git reset";
    gRh = "git reset --hard";
    gRs = "git reset --soft";
    gpristine = "git reset --hard && git clean -dffx";

    gS = "git stash";
    gSd = "git stash drop";
    gSl = "git stash list";
    gSs = "git stash show";

    gcl = "git clone";
    gclean = "git clean -id";
    gi = "git init";
    ghh = "git help";
    gignore = "git update-index --assume-unchanged";
    gignored = "git ls-files -v | grep '^[[:lower:]]'";
    gunignore = "git update-index --no-assume-unchanged";
  };
}
