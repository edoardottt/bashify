# bashify
Powershell profile to bashify your Windows prompt

How does it work? 🔍
--------
Read more about profiles [here](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7.2).  
If you can't run the script it's likely you should change your [execution policy](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7.2). Remember to restore it once finished. 

Installation 📥
------
- Locate the Powershell home with `echo $PSHOME` (likely to be `C:\Windows\System32\WindowsPowerShell\v1.0`)
- Save the file `Microsoft.PowerShell_profile.ps1` (with this exact name) inside that folder
- Close the terminal and reopen it

Commands 🛠️
------
- [x] alias c=clear
- [x] alias l=ls
- [x] touch
- [x] uname
- [x] cut
- [x] df
- [x] head
- [x] tail
- [x] zip
- [x] unzip
- [ ] [du](http://langexplr.blogspot.com/2007/03/implementation-of-du-s-in-powershell.html)
- [ ] [grep](https://www.thomasmaurer.ch/2011/03/powershell-search-for-string-or-grep-for-powershell/)
- [ ] [top](https://superuser.com/questions/176624/linux-top-command-for-windows-powershell)
- [ ] [sed](https://stackoverflow.com/questions/9682024/how-to-do-what-head-tail-more-less-sed-do-in-powershell)

Sources 🙏🏻
------
- [PowerShell equivalents for common Linux/bash commands](https://mathieubuisson.github.io/powershell-linux-bash/)
- [What is an equivalent of \*Nix 'cut' command in Powershell?](https://stackoverflow.com/questions/24634022/what-is-an-equivalent-of-nix-cut-command-in-powershell)
- [Get-DiskFree.ps1](https://gist.github.com/mweisel/3c357eba86ac6cae15b2)
- [How to do what head, tail, more, less, sed do in Powershell?](https://stackoverflow.com/questions/9682024/how-to-do-what-head-tail-more-less-sed-do-in-powershell)
- [Using PowerShell to Create ZIP Archives and Unzip Files](https://blog.netwrix.com/2018/11/06/using-powershell-to-create-zip-archives-and-unzip-files/).

Changelog 📌
-------
Detailed changes for each release are documented in the [release notes](https://github.com/edoardottt/bashify/releases).

Contributing 🤝
------
If you want to contribute to this project, you can start opening an [issue](https://github.com/edoardottt/bashify/issues).

License 📝
-------

This repository is under [GNU General Public License v3.0](https://github.com/edoardottt/bashify/blob/main/LICENSE).  
[edoardoottavianelli.it](https://www.edoardoottavianelli.it) to contact me.
