

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


master = Synth.new(\master, [\inbus, outbus]);

discreteBins = Array.fill(6, {|c| c + 1});
discreteBins.postln;

a = Scale.minor;

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

],4);


seq = Pseq([c],inf).play(tc);
seq.mute;

OSCdef(\param).clear;

OSCdef(\param, {|msg|

	if(msg[1] == 2){
		var disc = -1;


		discreteBins.do{|item, count|
			if(msg[3] <= item && disc == -1){disc = count};
		};




		if(currentDiscrete != disc){

			currentDiscrete = disc;

			if(disc == 0){a = Scale.major; seq.stream = Pseq([c],inf).asStream};
			if(disc == 1){a = Scale.major; seq.stream = Pseq([f2],inf).asStream};
			if(disc == 2){a = Scale.major; seq.stream = Pseq([g],inf).asStream};
			if(disc == 3){a = Scale.major; seq.stream = Pseq([c],inf).asStream};
			if(disc == 4){a = Scale.major; seq.stream = Pseq([f2],inf).asStream};
			if(disc == 5){a = Scale.major; seq.stream = Pseq([g],inf).asStream};

		};



		if(msg[3] < 0.1,{

			if(isMuted == false, {isMuted = true; seq.mute});

			},{

				var nt, na;
				if(isMuted == true, {isMuted = false; seq.unmute});
				nt = ControlSpec(20/60, 120/60, warp:'exp').map(msg[2]);
				na = ControlSpec(0.3,0.8).map(msg[2]);
				master.set(\amp, na);
				tc.tempo_(nt);
		});

	};

}, '/OSCSynth/params');

)












