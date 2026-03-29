-- Create words table for Supabase with Row Level Security (RLS)
CREATE TABLE IF NOT EXISTS public.words (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    word_text TEXT NOT NULL,
    total_count INTEGER DEFAULT 1,
    is_known BOOLEAN DEFAULT false,
    last_updated TIMESTAMPTZ NOT NULL
);

-- Optimization: index for common lookup and merge checks
CREATE UNIQUE INDEX IF NOT EXISTS idx_words_user_word_text ON public.words(user_id, word_text);

-- Partial index for library filtering by known words
CREATE INDEX IF NOT EXISTS idx_words_user_known ON public.words(user_id) WHERE is_known = true;

-- Enable RLS
ALTER TABLE public.words ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only access their own words
CREATE POLICY "Users can only access their own words" 
ON public.words 
FOR SELECT 
USING (auth.uid() = user_id);

-- Policy: Users can insert their own words
CREATE POLICY "Users can insert their own words" 
ON public.words 
FOR INSERT 
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own words
CREATE POLICY "Users can update their own words" 
ON public.words 
FOR UPDATE 
USING (auth.uid() = user_id) 
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can delete their own words
CREATE POLICY "Users can delete their own words" 
ON public.words 
FOR DELETE 
USING (auth.uid() = user_id);
