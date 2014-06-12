# ZendeskTools

Tools to automate common tasks in ZenDesk.

## Installation

Install the gem:

    $ gem install zendesk-tools

## Usage

Add a JSON config to ~/.zendesk-tools.json (TODO: make command line ovveride):

```javascript
{

    // mandatory
    "username": "user@example.com",
    "token": "your_token_here",
    "url": "https://your_domain.zendesk.com/api/v2"

    //include at least one cause
    "delete_causes": ["cause1", "cause2"],
    "delete_subjects": ["subject1", "subject2"],
    "recover_causes": ["cause1", "cause2"],

    // optional
   "log_level": "debug",
   "log_file": "/some/path"
}
```

Clean suspended tickets:

    $ zendesk-tools clean-suspended

Upload files to ticket:

    $ zendesk-tools upload-files-to-ticket <ticket_id> <files>

Recover suspended tickets:

	$ zendesk-tools recover-suspended
