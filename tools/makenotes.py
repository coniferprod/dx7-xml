def midi_to_note_name(midi_number: int) -> str:
    """Converts a MIDI note number to its corresponding note name (e.g., 60 -> 'C4')."""
    if not (0 <= midi_number <= 127):
        raise ValueError("MIDI note number must be between 0 and 127.")
        
    # The 12 semitones in an octave, starting at C (MIDI 0 is C-1)
    NOTE_NAMES = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
    
    # Calculate note name using modulo
    note = NOTE_NAMES[midi_number % 12]
    
    # Calculate octave using integer division (MIDI 12 is C0, MIDI 0 is C-1)
    octave = (midi_number // 12) - 1
    
    return f"{note}{octave}"

print('<xs:restriction base="xs:string">')
for note in range(9, 108+1):
    print(f'    <xs:enumeration value="{midi_to_note_name(note)}"/>', sep=' ')
print('</xs:restriction>')
