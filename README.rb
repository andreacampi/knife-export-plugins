A set of export plugins for Chef's `knife`.

Install
=======

Just copy one or more of the files from the `knife/` subdirectory of this repo
to your knife plugin directory. That's either in your home or in your chef-repo:

    cp knife/* ~/.chef/plugins/knife
    cp knife/* <chef-repo>/.chef/plugins/knife

Usage
=====

Running `knife` with no arguments should now show three new options:

    knife data bag export all (options)
    knife node export all (options)
    knife role export all (options)

knife data bag export all
-------------------------

Exports all the data bags with their content in JSON format and writes them to the `data_bags`
directory of your chef-repo.

To help keep the SCM diffs manageable, the JSON object is sorted in a reasonable, stable way.
In particular:

* some well-known data bags are recognized, and their content is sorted in a way that makes sense
for humans;
* all other hashes are sorted alphabetically;
* arrays and plain strings are passed through unmodified

knife node export all
-------------------------

Exports all the nodes in JSON format and writes them to the `nodes` directory of your chef-repo.

To help keep the SCM diffs manageable, the JSON object is sorted in a reasonable, stable way.
In particular:

* only normal attributes are sorted (for now);
* the `log` attribute (used by [nuclearrooster's update handler](http://dev.nuclearrooster.com/2011/05/10/chef-notifying-and-logging-updated-resources/))
is removed;
* all other hashes are sorted alphabetically;
* arrays and plain strings are passed through unmodified

knife role export all
-------------------------

Exports all the roles in JSON format and writes them to the `nodes` directory of your chef-repo.

To help keep the SCM diffs manageable, the JSON object is sorted in a reasonable, stable way.
In particular:

* normal and override attributes are sorted;
* all other hashes are sorted alphabetically;
* arrays and plain strings are passed through unmodified

Author and License
==================

You can do whatever you want with this code :)
