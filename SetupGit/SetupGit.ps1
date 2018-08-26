$user = Read-Host "User Name"
git config --global user.name "$user"
$email = Read-Host "User Email"
git config --global user.email "$email"


git config --global alias.last "log -1 HEAD"
git config --global alias.psu "push --set-upstream"
git config --global alias.NUKE "reset --hard HEAD"
git config --global alias.stashes "stash list"
git config --global alias.s "status -s"

git config --get-regexp alias
#git log — all — grep=’commit message’
#git config --global alias.prum "pull --rebase upstream master"
