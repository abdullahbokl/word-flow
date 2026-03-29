CREATE OR REPLACE FUNCTION upsert_word_lww(
    p_id UUID,
    p_user_id UUID,
    p_word_text TEXT,
    p_total_count INT,
    p_is_known BOOLEAN,
    p_last_updated TIMESTAMPTZ
) RETURNS void AS $$
BEGIN
    INSERT INTO words (id, user_id, word_text, total_count, is_known, last_updated)
    VALUES (p_id, p_user_id, p_word_text, p_total_count, p_is_known, p_last_updated)
    ON CONFLICT (id) 
    DO UPDATE SET 
        total_count = EXCLUDED.total_count,
        is_known = EXCLUDED.is_known,
        last_updated = EXCLUDED.last_updated
    WHERE words.last_updated < EXCLUDED.last_updated;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
