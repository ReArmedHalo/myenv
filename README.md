# My Environment
Scripts and other bits of stuff to configure a computer/server for my personal use. :unamused:

Scripts Functionality includes / goals:

- [X] Install ZSH and load my `.zshrc` file :thumbsup:
- [X] Download my SSH key from my BitWarden instance :satisfied:
- [ ] Install and configure a full stack PHP development environment :worried:
  - [ ] Bonus points: Laravel Valet for Linux configuration (I will be writing about this one) :pensive:
- [X] Can be ran 99% unattended (Some scripts are going to require some input like BitWarden login) :muscle:
  - This is accomplished except since we don't run as sudo we may need multiple inputs for sudo
  - BitWarden login/unlock require user input as well
  - I don't see any way to fix the above so marking this task as accomplished
- [ ] Support macOS, Ubuntu and CentOS for all functions :boom:
  - [X] Script was written and tested on Ubuntu so thus far works on that
  - [ ] macOS had some function tests but not a full run to test everything
  - [ ] CentOS has not yet been tested
  
> This is a living repository and my initial commit was focused on this all being in one script, I've since decided to **_not_** do that but instead have everything split into it's own specialized script and have a nice selector menu to handle provisioning.
