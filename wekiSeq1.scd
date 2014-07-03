
//have variable number of bins
//midi out

(

SynthDef.new(\master, {|inbus, outbus, amp = 1|

	var sig;
	sig = In.ar(inbus, 1);
	sig = (sig * amp)!2;
	Out.ar(0, sig);
}).send(s);

)



(


var seq, currentDiscrete = 0, discreteBins, tc = TempoClock.new(120/60), isMuted = true, outbus, master, f2, phrases;

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

/*a = Scale.minor;

//C weighting

c = Pxrand([
	Pbind(\out, outbus, \scale, a, \degree,Pseq([0,2,4,2], 1), \dur, 0.25),
	Pbind(\out, outbus, \scale, a, \degree,Pseq([0,1,2,3], 1), \dur, 0.25),
	Pbind(\out, outbus, \scale, a, \degree,Pseq([7,6,5,4], 1), \dur, 0.25),
	Pbind(\out, outbus, \scale, a, \degree,Pxrand((0..7), 4), \dur, 0.25),
	Pbind(\out, outbus, \scale, a, \degree,Pseq([7,6,7], 1), \dur, Pseq([0.25,0.25,0.5],1))
],4);

//F weighting


f = Pxrand([
	Pbind(\out, outbus, \scale, a, \degree,Pseq([3,0,3,5], 1), \dur, 0.25),
	Pbind(\out, outbus, \scale, a, \degree,Pseq([10,0,3,5], 1), \dur, 0.25),
	Pbind(\out, outbus, \scale, a, \degree,Pseq([10,9,8,7,6,5,4], 1), \dur, 0.25)

],4);

f2 = Pxrand([
	Pbind(\out, outbus, \scale, a, \degree,Pseq([3,0,3,5].collect({ arg item, i; item + 7 }), 1), \dur, 0.25),
	Pbind(\out, outbus, \scale, a, \degree,Pseq([10,0,3,5].collect({ arg item, i; item + 7 }), 1), \dur, 0.25),
	Pbind(\out, outbus, \scale, a, \degree,Pseq([10,9,8,7,6,5,4].collect({ arg item, i; item + 7 }), 1), \dur, 0.25)

],4);


//G weighting


g = Pxrand([
	Pbind(\out, outbus, \scale, a, \degree,Pseq([1,4,6,4], 1), \dur, 0.25),
	Pbind(\out, outbus, \scale, a, \degree,Pseq([1,4,6,3], 1), \dur, 0.25),
	Pbind(\out, outbus, \scale, a, \degree,Pseq([1,2,3,4], 1), \dur, 0.25),
	Pbind(\out, outbus, \scale, a, \degree,Pseq([3,3,3,4], 1), \dur, 0.25)

],4);*/


seq = Pseq([phrases[0]],inf).play(tc);

OSCdef(\param).clear;

OSCdef(\param, {|msg|

	var disc = -1;


	discreteBins.do{|item, count|
		if(msg[2] <= item && disc == -1){disc = count};
	};




	/*if(currentDiscrete != disc){

		currentDiscrete = disc;

		if(disc == 0){a = Scale.major; seq.stream = Pseq([c],inf).asStream};
		if(disc == 1){a = Scale.major; seq.stream = Pseq([f2],inf).asStream};
		if(disc == 2){a = Scale.major; seq.stream = Pseq([g],inf).asStream};
		if(disc == 3){a = Scale.major; seq.stream = Pseq([c],inf).asStream};
		if(disc == 4){a = Scale.major; seq.stream = Pseq([f2],inf).asStream};
		if(disc == 5){a = Scale.major; seq.stream = Pseq([g],inf).asStream};

	};*/


	if(currentDiscrete != disc , {

		if(disc == -1){disc = 0};
		currentDiscrete.post;
		disc.postln;

		currentDiscrete = disc;
		a = Scale.major;
		seq.stream = Pseq([phrases[disc]],inf).asStream;
	});


	/*if(msg[2] < 0.1,{

		if(isMuted == false, {isMuted = true; seq.mute});

		},{

			var nt, na;
			if(isMuted == true, {isMuted = false; seq.unmute});
			nt = ControlSpec(20/60, 120/60, warp:'exp').map(msg[2]);
			na = ControlSpec(0.3,0.8).map(msg[2]);
			master.set(\amp, na);
			tc.tempo_(nt);
	});*/

}, '/OSCSynth/params');

)












