# Queue

## Queue Configuration
#### Amount of Workers
The amount of queue worker processes is specified in `defaults.json`.
```json
{
  "queue": {
    "workers": {
      "amount": 1
    }
  }
}
```
#### Restart Delay
The delay when a worker restarts is set in `defaults.json`.
```json
{
  "queue": {
    "workers": {
      "restart_delay": 0.2
    }
  }
}
```
#### Queued Mail Directory
The directory queued mails are stored in is set in `defaults.json`.
```json
{
  "queue": {
    "queued_mail_dir": "data/queued_mail"
  }
}
```
#### Remove Mail on Unqueue
Whether queued mails stored in the above directory is deleted upon
being unqueued (either from being unqueued manually or once delivered)
is set in `defaults.json`.
```json
{
  "queue": {
    "remove_on_unqueue": true
  }
}
```
#### Return Queue ID's
Whether to return message queue ID's after a message is submitted is
set in `defaults.json`.
```json
{
  "queue": {
    "return_queue_ids": true
  }
}
```

## mlsmtpqueue
The `mlsmtpqueue` tool can be used to modify the queue.
```
MLSMTP Email List Manager
Usage: mlsmtpqueue <list> [options]

Options:
  --conf: specify MLSMTP configuration file
  --help: print this help menu
  --eqmod <eq>:<mod>: list queued messages where the mid % <mod> == eq
  --unqueue_uid <uid>: unqueue message with UID <uid>
  --mid <mid>: display message with MID <mid>
  --uid <uid>: display message with UID <uid>
  --count: only display amount of messages in queue
  --clear: clear all queued messages
```
