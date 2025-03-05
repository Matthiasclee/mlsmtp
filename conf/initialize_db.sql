CREATE TABLE IF NOT EXISTS queued_messages (
    message_id INTEGER PRIMARY KEY AUTOINCREMENT, 
    created_at INTEGER NOT NULL, 
    mail_from TEXT NOT NULL, 
    rcpt_to TEXT NOT NULL, 
    file_path TEXT NOT NULL,
    UNIQUE(message_id)
);
