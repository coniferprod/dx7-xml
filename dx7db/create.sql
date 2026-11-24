create table if not exists cartridge (
    cartridge_id TEXT PRIMARY KEY NOT NULL,  -- UUID
    name TEXT NOT NULL,
    data BLOB
);

create table if not exists voice (
    voice_id TEXT PRIMARY KEY NOT NULL,  -- UUID
    name TEXT NOT NULL CHECK(length(name) = 10),
    -- operators for this voice are found in the voice_operator table
    algorithm INTEGER NOT NULL DEFAULT 32 CHECK(algorithm BETWEEN 1 AND 32),
    feedback INTEGER NOT NULL DEFAULT 0 CHECK(feedback BETWEEN 0 AND 7),
    osc_sync BOOLEAN NOT NULL DEFAULT FALSE,
    lfo_id TEXT NOT NULL,  -- foreign key to the lfo table
    peg_id TEXT NOT NULL,  -- foreign key to the eg table
    pms INTEGER NOT NULL DEFAULT 0 CHECK(pms BETWEEN 0 AND 7),  -- applies to all operators
    transpose INTEGER NOT NULL DEFAULT 0 CHECK(transpose BETWEEN -24 AND 24),  -- number of semitones to transpose (12 = C2 (value is 0~48 in SysEx))
    
    data BLOB, -- the original System Exclusive payload

    FOREIGN KEY (lfo_id) REFERENCES lfo(lfo_id),
    FOREIGN KEY (peg_id) REFERENCES eg(eg_id)
);

create table if not exists cartridge_voice ( -- the voices in a cartridge
    cartridge_id TEXT NOT NULL,
    voice_id TEXT NOT NULL,
    voice_number INTEGER NOT NULL,
    PRIMARY KEY (cartridge_id, voice_id)
);

create table if not exists eg (
    eg_id TEXT NOT NULL, -- UUID
    rates TEXT NOT NULL,  -- 99 99 99 99
    levels TEXT NOT NULL  -- 99 99 99 99
);

create table if not exists lfo (
    lfo_id TEXT NOT NULL,  -- UUID
    speed INTEGER NOT NULL DEFAULT 0 CHECK(speed BETWEEN 0 AND 99),
    delay INTEGER NOT NULL DEFAULT 0 CHECK(delay BETWEEN 0 AND 99),
    pmd INTEGER NOT NULL DEFAULT 0 CHECK(pmd BETWEEN 0 AND 99),
    amd INTEGER NOT NULL DEFAULT 0 CHECK(amd BETWEEN 0 AND 99),
    sync BOOLEAN NOT NULL DEFAULT FALSE,
    waveform TEXT NOT NULL CHECK(waveform IN ('triangle', 'saw-down', 'saw-up', 'square', 'sine', 'sample-and-hold'))
);

create table if not exists kls (
    kls_id TEXT NOT NULL,  -- UUID
    breakpoint INTEGER NOT NULL DEFAULT 0 CHECK(breakpoint BETWEEN 0 AND 99),
    left TEXT NOT NULL,  -- nn +LIN 
    right TEXT NOT NULL  -- nn +EXP
);

create table if not exists operator (
    op_id TEXT NOT NULL,  -- UUID
    eg_id TEXT NOT NULL,
    kls_id TEXT NOT NULL,
    kbd_rate_scaling INTEGER NOT NULL DEFAULT 0 CHECK(kbd_rate_scaling BETWEEN 0 AND 7),
    ams INTEGER NOT NULL DEFAULT 0 CHECK(ams BETWEEN 0 AND 3),
    key_vel_sens INTEGER NOT NULL DEFAULT 0 CHECK(key_vel_sens BETWEEN 0 AND 7),
    level INTEGER NOT NULL DEFAULT 0 CHECK(level BETWEEN 0 AND 99),
    mode TEXT NOT NULL DEFAULT 'ratio' CHECK(mode IN ('ratio', 'fixed')),
    coarse INTEGER NOT NULL DEFAULT 0 CHECK(coarse BETWEEN 0 AND 31),
    fine INTEGER NOT NULL DEFAULT 0 CHECK(fine BETWEEN 0 AND 99),
    detune INTEGER NOT NULL DEFAULT 0 CHECK(detune BETWEEN -7 AND 7),

    FOREIGN KEY (eg_id) REFERENCES eg(eg_id),
    FOREIGN KEY (kls_id) REFERENCES kls(kls_id)
);

create table if not exists voice_operator (
    voice_id TEXT NOT NULL,
    op_id TEXT NOT NULL,
    op_num INTEGER NOT NULL CHECK(op_num BETWEEN 1 AND 6),

    PRIMARY KEY (voice_id, op_id)
);

