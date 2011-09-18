Cart
====

Cart is a Rakefile-based method to create custom Apple packages and DMG files.  Cart creates a directory structure and utilizes the packagemaker command line tool to create package files.

Requirements
------------

You must have the following installed:

* git (to download source)
* Developer Tools (for Packagemaker Binary)
* Rubygems (installed by default on OS X)
* Rake rubygem (gem install rake)

Downloading Cart
----------------

I use a git submodule in the examples directory since the example code is its own repository (https://github.com/glarizza/cart-examples).  In order to download all the code from the submodule, you must use the --recursive argument to git like this:

    git clone https://github.com/glarizza/Cart --recursive

If you *DO NOT* pass theh --recursive flag, your /examples directory will be empty.  Also note that clicking the Downloads button to download a copy of this repository from Github *WILL NOT* download the example submodule (so make sure to use git to download the source).

Using Cart
----------

To use cart, clone the repository to your local file system, change to the examples directory and to the example module for which you want to build a package, and do one of the following:

    rake dmg
    rake pkg
    rake zip

To see all the available actions on that Rakefile, run the following command:

    rake -T