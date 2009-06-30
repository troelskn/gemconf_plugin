gemconf plugin
===

This small plugin to Rails solves the problem that `rake gems:install` depends on Rake, which loads all tasks in the current subtree. Since a task can have load-time dependencies on gems, this might prevent Rake from starting up, thus making it inpossible to run the task, that should install the missing gems. A classical catch-22.

The plugin moves gem dependencies into `config/gemconf.rb` and adds the script `script/install_gems` to your Rails project.
After that, you can install gems with `script/install_gems`. This is a simple script, that doesn't have any gem dependencies, thus guaranteeing it to run, as long as Ruby and rubygems are installed.

Copyright: [Unwire A/S](http://www.unwire.dk), 2009

License: [Creative Commons Attribution 2.5 Denmark License](http://creativecommons.org/licenses/by/2.5/dk/deed.en_GB)

___

troelskn@gmail.com - June, 2009