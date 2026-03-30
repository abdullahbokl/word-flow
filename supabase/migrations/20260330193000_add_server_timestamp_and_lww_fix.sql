ALTER TABLE public.words
ADD COLUMN IF NOT EXISTS server_timestamp TIMESTAMPTZ NOT NULL DEFAULT now();

CREATE OR REPLACE FUNCTION public.now_trigger_fn()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.server_timestamp = now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS set_server_timestamp ON public.words;

CREATE OR REPLACE TRIGGER set_server_timestamp
BEFORE INSERT OR UPDATE ON public.words
FOR EACH ROW
EXECUTE FUNCTION public.now_trigger_fn();

CREATE OR REPLACE FUNCTION upsert_word_lww(
    p_id UUID,
    p_user_id UUID,
    p_word_text TEXT,
    p_total_count INT,
    p_is_known BOOLEAN,
    p_last_updated TIMESTAMPTZ
) RETURNS void AS $$
BEGIN
    INSERT INTO words (
      id,
      user_id,
      word_text,
      total_count,
      is_known,
      last_updated,
      server_timestamp
    )
    VALUES (
      p_id,
      p_user_id,
      p_word_text,
      p_total_count,
      p_is_known,
      p_last_updated,
      now()
    )
    ON CONFLICT (id)
    DO UPDATE SET
        total_count = EXCLUDED.total_count,
        is_known = EXCLUDED.is_known,
        last_updated = EXCLUDED.last_updated,
        server_timestamp = EXCLUDED.server_timestamp
    WHERE words.server_timestamp < EXCLUDED.server_timestamp;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
