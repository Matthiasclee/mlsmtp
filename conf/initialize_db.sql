CREATE TABLE IF NOT EXISTS queued_messages (
    message_id INTEGER PRIMARY KEY AUTOINCREMENT, 
    message_uid INTEGER NOT NULL,
    is_error_response INTEGER NOT NULL,
    created_at INTEGER NOT NULL, 
    mail_from TEXT NOT NULL, 
    rcpt_to TEXT NOT NULL, 
    file_path TEXT NOT NULL,
    retries INTEGER NOT NULL,
    try_at INTEGER NOT NULL,
    UNIQUE(message_id)
);

CREATE TABLE IF NOT EXISTS mail_lists (
    id INTEGER PRIMARY KEY AUTOINCREMENT, 
    name TEXT NOT NULL,
    UNIQUE(id),
    UNIQUE(name)
);

CREATE TABLE IF NOT EXISTS list_memberships (
    email TEXT NOT NULL,
    list_id INTEGER NOT NULL,
    UNIQUE(email, list_id)
);
