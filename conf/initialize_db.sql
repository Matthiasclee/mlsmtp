CREATE TABLE queued_messages (
    message_id INTEGER PRIMARY KEY AUTOINCREMENT, 
    created_at INTEGER NOT NULL, 
    rcpt_to TEXT NOT NULL, 
    mail_from TEXT NOT NULL, 
    file_path TEXT NOT NULL,
    UNIQUE(message_id)
);
