# ZendeskTools

Tools to automate common tasks in FINNs ZenDesk.

## Installation

Install the gem:

    $ gem install zendesk-tools --source "http://gems.finn.no"

## Usage

Add a JSON config to ~/.zendesk-tools.json (TODO: make command line ovveride):

    {

      // mandatory
      "username": "jari@finn.no",
      "token": "f1d2d2f924e986ac....",

      // optional
      "log_level": "debug",
      "log_file": "/some/path"

    }

Clean suspended tickets:

    $ zendesk-tools clean-suspended

Upload files to ticket:

    $ zendesk-tools upload-files-to-ticket <ticket_id> <files>


