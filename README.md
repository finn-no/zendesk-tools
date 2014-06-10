# ZendeskTools

Tools to automate common tasks in ZenDesk.

## Installation

Install the gem:

    $ gem install zendesk-tools

## Usage

Add a JSON config to ~/.zendesk-tools.json (TODO: make command line ovveride):

    {

      // mandatory
      "username": "user@example.com",
      "token": "your_token_here",

      // optional
      "log_level": "debug",
      "log_file": "/some/path"

    }

Clean suspended tickets:

    $ zendesk-tools clean-suspended

Upload files to ticket:

    $ zendesk-tools upload-files-to-ticket <ticket_id> <files>

Recover suspended tickets:

	$ zendesk-tools recover-suspended
