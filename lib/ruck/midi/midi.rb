
require "midilib"
require "midiator"

module Ruck
  module MIDI
    
    class MIDIShreduler < Ruck::Shreduler
      attr_reader :midi
      
      def initialize(midi, real_time)
        super()
        @midi = midi
        @real_time = real_time
      end
      
      def run
        @start_time = Time.now
        super
      end
  
      def fast_forward(dt)
        super
        
        @midi.tick(dt)
    
        # sync with wall clock
        if @real_time
          actual_now = Time.now
          simulated_now = @start_time + (now.to_f / @midi.ppqn / @midi.bpm * 60.0)
          if simulated_now > actual_now
            sleep(simulated_now - actual_now)
          end
        end
      end
    end

    class MIDIOutput
      def initialize(real_time, save_filename = nil, num_tracks = 1)
        if save_filename
          @filename = save_filename
          @sequence = ::MIDI::Sequence.new
          @tracks = (1..num_tracks).map { ::MIDI::Track.new(@sequence) }
          @track_deltas = @tracks.map { 0 }
      
          @tracks.each do |track|
            @sequence.tracks << track
            #track.events << ::MIDI::Tempo.new(::MIDI::Tempo.bpm_to_mpq(120))
          end
        end
    
        if real_time
          @player = MIDIator::Interface.new
          @player.use :dls_synth
          @player.instruct_user!
        end
      end
      
      def ppqn
        @sequence.ppqn
      end
      
      def bpm
        @sequence.bpm
      end
  
      def tick(delta)
        if @sequence
          @track_deltas.each_with_index do |track_delta, i|
            @track_deltas[i] = track_delta + delta
          end
        end
      end
  
      def note_on(note, velocity = 127, channel = 0, track = 0)
        if @sequence
          @tracks[track].events << ::MIDI::NoteOnEvent.new(channel, note, velocity, @track_deltas[track].to_i)
          @track_deltas[track] = 0
        end
        
        if @player
          @player.driver.note_on(note, channel, velocity)
        end
      end
  
      def note_off(note, channel = 0, track = 0)
        if @sequence
          @tracks[track].events << ::MIDI::NoteOffEvent.new(channel, note, 0, @track_deltas[track].to_i)
          @track_deltas[track] = 0
        end
        
        if @player
          @player.driver.note_on(note, channel, 0)
        end
      end
      
      def control_change(controller, value, channel = 0, track = 0)
        if @sequence
          @tracks[track].events << ::MIDI::Controller.new(channel, controller, value)
        end
        
        if @player
          @player.driver.control_change(controller, channel, value)
        end
      end
      
      def program_change(program, channel = 0, track = 0)
        if @sequence
          @tracks[track].events << ::MIDI::ProgramChange.new(channel, program)
        end
        
        if @player
          @player.driver.program_change(channel, program)
        end
      end
  
      def save
        return if @saved
        return unless @sequence
    
        @saved = true
    
        File.open(@filename, "wb") do |file|
          @sequence.write(file)
        end
      end
    end

    # stuff accessible in a shred
    module ShredLocal
      def now
        SHREDULER.now
      end

      def wait(pulses)
        Shred.yield(pulses)
      end
  
      def note_on(note, velocity = 127, channel = 0, track = 0)
        SHREDULER.midi.note_on(note, velocity, channel, track)
      end
  
      def note_off(note, channel = 0, track = 0)
        SHREDULER.midi.note_off(note, channel, track)
      end
      
      def control_change(controller, value, channel = 0, track = 0)
        SHREDULER.midi.control_change(controller, value, channel, track)
      end
      
      def program_change(program, channel = 0, track = 0)
        SHREDULER.midi.program_change(program, channel, track)
      end
    end
    
  end
end

# set up some useful time helpers
module MIDITime
  def pulse
    self
  end
  alias_method :pulses, :pulse
  
  def quarter_note
    self * SHREDULER.midi.ppqn
  end
  alias_method :quarter_notes, :quarter_note
  alias_method :beat, :quarter_note
  alias_method :beats, :quarter_note
end

class Fixnum
  include MIDITime
end

class Float
  include MIDITime
end
