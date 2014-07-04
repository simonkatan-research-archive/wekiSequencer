
//have variable number of bins

(

SynthDef.new(\master, {|inbus, outbus, amp = 1|

	var sig;
	sig = In.ar(inbus, 1);
	sig = (sig * amp)!2;
	Out.ar(0, sig);
}).send(s);

)


(


var seq, currentDiscrete = 0, discreteBins, tc = TempoClock.new(120/60), isMuted = true, outbus, master, phrases;

outbus = Bus.audio(s, 1);


phrases = [

	Pbind(\out, outbus, \scale, a, \degree,Pseq([0], 1), \dur, 0.25),
	Pbind(\out, outbus, \scale, a, \degree,Pseq([0,1,2,3], 1), \dur, 0.25),
	Pbind(\out, outbus, \scale, a, \degree,Pseq([4,5,6,7], 1), \dur, 0.25),
	Pbind(\out, outbus, \scale, a, \degree,Pseq([7,6,5,4], 1), \dur, 0.25),
	Pbind(\out, outbus, \scale, a, \degree,Pseq([3,2,1], 1), \dur,0.25),
	Pbind(\out, outbus, \scale, a, \degree,Pseq([1,3,5], 1), \dur, 0.25),
	Pbind(\out, outbus, \scale, a, \degree,Pseq([0,2,4], 1), \dur, 0.25),
	Pbind(\out, outbus, \scale, a, \degree,Pseq((0..7), 1), \dur, 0.25),
	Pbind(\out, outbus, \scale, a, \degree,Pseq([6], 1), \dur, 0.25)

];

master = Synth.new(\master, [\inbus, outbus]);

discreteBins = Array.fill(phrases.size(), {|c| c + 1 * 1/phrases.size()});
discreteBins.postln;


seq = Pseq([phrases[0]],inf).play(tc);

OSCdef(\param).clear;

OSCdef(\param, {|msg|

	var disc = -1;


	discreteBins.do{|item, count|
		if(msg[2] <= item && disc == -1){disc = count};
	};

	if(disc == -1){disc = phrases.size()-1};

	if(currentDiscrete != disc , {

		disc.postln;
		currentDiscrete = disc;
		a = Scale.major;
		seq.stream = Pseq([phrases[disc]],inf).asStream;
	});




}, '/OSCSynth/params');

)












