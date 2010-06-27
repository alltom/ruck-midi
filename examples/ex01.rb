
def maybe
  rand >= 0.5
end

control_change(32, 1, 10)
program_change(26, 10)

def play(note, dur = 1.quarter_note)
  return if maybe
  note_on note, 100, 10
  wait dur
  note_off note, 10
end

30.times do
  spork { play(rand(30) + 40, rand * 3.quarter_notes + 3.quarter_notes) }
  wait 0.5.quarter_note
end

wait 2.quarter_notes; note_off 0 # end padding
